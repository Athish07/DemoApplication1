import Foundation

final class BookingImpl: BookingService {

 
    private let seatManager: SeatManagerService
    private let seatRepo: SeatRepoService
    private let ticketRepo: TicketRepoService
    private let trainRepo: TrainRepoService

    private init(
        seatManager: SeatManagerService,
        seatRepo: SeatRepoService,
        ticketRepo: TicketRepoService,
        trainRepo: TrainRepoService
    ) {
        self.seatManager = seatManager
        self.seatRepo = seatRepo
        self.ticketRepo = ticketRepo
        self.trainRepo = trainRepo
    }
     
    static func build(
        seatManager: SeatManagerService,
        seatRepo: SeatRepoService,
        ticketRepo: TicketRepoService,
        trainRepo: TrainRepoService
    ) -> BookingService {
        return BookingImpl(
            seatManager: seatManager,
            seatRepo: seatRepo,
            ticketRepo: ticketRepo,
            trainRepo: trainRepo
        )
    }
     
    func bookTicket(
        user: User,
        train: Train,
        passengerName: String,
        age: UInt,
        gender: String,
        seatPreference: String,
        source: Location,
        destination: Location,
        journeyDate: Date
    ) -> Ticket? {
        
        let segments = seatManager.getSegmentsBetween(
            train.trainNumber,
            source,
            destination
        )

        guard !segments.isEmpty else { return nil }

        let key = compositeKey(train.trainNumber, journeyDate)

        let confirmedAvailable = seatManager.isConfirmedSeatAvailable(
            trainNumber: train.trainNumber,
            journeyDate: journeyDate,
            source: source,
            destination: destination
        )

        if confirmedAvailable {

            let allocatedSeat = seatManager.allocateSeat(
                trainNumber: train.trainNumber,
                journeyDate: journeyDate,
                seatPreference: seatPreference,
                source: source,
                destination: destination
            )
            
            let ticket = Ticket(
                trainNumber: train.trainNumber,
                trainName: train.trainName,
                userId: user.userId,
                userName: passengerName,
                age: age,
                gender: gender,
                seatPreference: seatPreference,
                allocatedSeat: allocatedSeat,  
                source: source,
                destination: destination,
                dateOfJourney: journeyDate,
                ticketStatus: .confirmed,
            )

            ticketRepo.save(ticket)
            ticketRepo.addHistory(
                ticket.ticketId,
                TicketStatusHistory(date: Date(), status: .confirmed)
            )

            return ticket
        }

        let racQueueCount = seatRepo.racQueueCount(for: key)

        if racQueueCount >= Int(train.totalRACSeats) {

            return bookWaitingListTicket(
                train: train,
                user: user,
                passengerName: passengerName,
                age: age,
                gender: gender,
                seatPreference: seatPreference,
                source: source,
                destination: destination,
                normalizedDate: journeyDate,
                key: key,
                segments: segments
            )
        }

        let racPosition = racQueueCount + 1
        let racSeatNumber = ((racPosition - 1) / 2) + 1
        let racSeat = "RAC-SEAT-\(racSeatNumber)"
        let racLabel = "RAC\(racPosition)"

        let ticket = Ticket(
            trainNumber: train.trainNumber,
            trainName: train.trainName,
            userId: user.userId,
            userName: passengerName,
            age: age,
            gender: gender,
            seatPreference: seatPreference,
            allocatedSeat: "\(racSeat) (\(racLabel))",
            source: source,
            destination: destination,
            dateOfJourney: journeyDate,
            ticketStatus: .rac
        )

       
        seatRepo.saveRACQueue(ticket, for: key)

        for seg in segments {
            seatRepo.addBookedSeat(
                trainNumber: train.trainNumber,
                date: journeyDate,
                segment: seg,
                seat: racSeat
            )
        }

        ticketRepo.save(ticket)
        ticketRepo.addHistory(
            ticket.ticketId,
            TicketStatusHistory(date: Date(), status: .rac)
        )

        return ticket
    }

    private func bookWaitingListTicket(
        train: Train,
        user: User,
        passengerName: String,
        age: UInt,
        gender: String,
        seatPreference: String,
        source: Location,
        destination: Location,
        normalizedDate: Date,
        key: String,
        segments: [String]
    ) -> Ticket? {

        let waitingListCount: Int = seatRepo.waitingListCount(for: key)

        if waitingListCount >= Int(train.totalWaitingSeats) {
            
            return nil
        }

        let wlPosition = waitingListCount + 1
        let wlLabel = "WL\(wlPosition)"

        let ticket = Ticket(
            trainNumber: train.trainNumber,
            trainName: train.trainName,
            userId: user.userId,
            userName: passengerName,
            age: age,
            gender: gender,
            seatPreference: seatPreference,
            allocatedSeat: wlLabel,
            source: source,
            destination: destination,
            dateOfJourney: normalizedDate,
            ticketStatus: .waitingList
        )
        
        seatRepo.saveWaitingList(ticket, for: key)

        ticketRepo.save(ticket)
        ticketRepo.addHistory(
            ticket.ticketId,
            TicketStatusHistory(date: Date(), status: .waitingList)
        )

        return ticket
    }

    func cancelTicket(ticketId: Int) -> Bool {

        guard let ticket = ticketRepo.findById(ticketId) else { return false }

        let originalStatus = ticket.ticketStatus
        let trainNumber = ticket.trainNumber
        let date = ticket.dateOfJourney

        if originalStatus == .confirmed || originalStatus == .rac {
            releaseSeat(ticket: ticket)
        }

        var cancelled = ticket
        cancelled.updateTicketStatus(.cancelled)
        ticketRepo.save(cancelled)

        ticketRepo.addHistory(
            cancelled.ticketId,
            TicketStatusHistory(date: Date(), status: .cancelled)
        )

        if originalStatus == .confirmed {
            promoteFromRAC(trainNumber: trainNumber, journeyDate: date)
        } else if originalStatus == .rac {
            promoteFromWaiting(trainNumber: trainNumber, journeyDate: date)
        }

        return true
    }

    func promoteFromRAC(trainNumber: Int, journeyDate: Date) {

        let key = compositeKey(trainNumber, journeyDate)
        
        guard var racTicket = seatRepo.removeRACSeat(for: key) else { return }

        let newSeat = seatManager.allocateSeat(
            trainNumber: trainNumber,
            journeyDate: journeyDate,
            seatPreference: racTicket.seatPreference,
            source: racTicket.source,
            destination: racTicket.destination
        )

        racTicket.updateTicketStatus(.confirmed)
        racTicket.updateAllocatedSeat(newSeat)

        ticketRepo.save(racTicket)

        ticketRepo.addHistory(
            racTicket.ticketId,
            TicketStatusHistory(date: Date(), status: .confirmed)
        )
        
        promoteFromWaiting(trainNumber: trainNumber, journeyDate: journeyDate)
    }

    func promoteFromWaiting(trainNumber: Int, journeyDate: Date) {

        let key = compositeKey(trainNumber, journeyDate)
        let racQueueCount = seatRepo.racQueueCount(for: key)
        guard var ticket = seatRepo.removeWaitingListSeat(for : key) else {
            return
        }
        
        let racPosition = racQueueCount + 1
        let racSeatNumber = ((racPosition - 1) / 2) + 1
        let racSeat = "RAC-SEAT-\(racSeatNumber)"
        let racLabel = "RAC\(racPosition)"

        ticket.updateTicketStatus(.rac)
        ticket.updateAllocatedSeat("\(racSeat) (\(racLabel))")
        
        seatRepo.saveRACQueue(ticket, for: key)

        ticketRepo.save(ticket)

        ticketRepo.addHistory(
            ticket.ticketId,
            TicketStatusHistory(date: Date(), status: .rac)
        )
    }

    private func releaseSeat(ticket: Ticket) {

        let segments = seatManager.getSegmentsBetween(
            ticket.trainNumber,
            ticket.source,
            ticket.destination
        )

        let cleanSeat = String(ticket.allocatedSeat.prefix { $0 != "(" })
            .trimmingCharacters(in: .whitespaces)

        var trainBookedMap = seatRepo.getBookedSeats(
            trainNumber: ticket.trainNumber
        )

        var dayMap = trainBookedMap[ticket.dateOfJourney] ?? [:]

        for seg in segments {
            dayMap[seg]?.remove(cleanSeat)
        }

        trainBookedMap[ticket.dateOfJourney] = dayMap

        seatRepo.updateBookedSeats(
            trainNumber: ticket.trainNumber,
            updatedMap: trainBookedMap
        )
    }
     
    func getUserBookingHistory(userId: Int) -> [Ticket] {
        ticketRepo.findByUser(userId)
    }

    private func compositeKey(_ trainNumber: Int, _ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(trainNumber)_\(formatter.string(from: date))"
    }
}
