import Foundation

final class SeatManagerImpl: SeatManagerService {

    private let seatRepo: SeatRepository
    private let trainRepo: TrainRepository

    private init(seatRepo: SeatRepository, trainRepo: TrainRepository) {
        self.seatRepo = seatRepo
        self.trainRepo = trainRepo
    }
    
    static func build(
        seatRepo: SeatRepository,
        trainRepo: TrainRepository
    ) -> SeatManagerService {
        return SeatManagerImpl(seatRepo: seatRepo, trainRepo: trainRepo)
    }
    
    func initializeSeatsForTrain(
        trainNumber: Int,
        journeyDate: Date,
        routeId: Int,
        totalConfirmedSeats: UInt,
        totalRACSeats: UInt,
        totalWaitingSeats: UInt
    ) {
        let stations = trainRepo.getRoutes(routeId)
        guard stations.count > 1 else { return }

        var segmentSeats: [String: [String]] = [:]
        
        for i in 0..<(stations.count - 1) {
            let from = stations[i]
            let to = stations[i + 1]
            let segmentKey = AppHelper.segmentKey(from: from, to: to)

            let confirmedSeats = generateConfirmedSeats(totalConfirmedSeats)
            segmentSeats[segmentKey] = confirmedSeats
        }

        seatRepo.ensureSeatsGenerated(
            trainNumber: trainNumber,
            date: journeyDate,
            segmentSeats: segmentSeats
        )
    }

    func isConfirmedSeatAvailable(
        trainNumber: Int,
        journeyDate: Date,
        source: Location,
        destination: Location
    ) -> Bool {

        let segments = getSegmentsBetween(trainNumber, source, destination)
        if segments.isEmpty { return false }

        guard
            let seatMap = seatRepo.getSeats(trainNumber: trainNumber)[
                journeyDate
            ],
            let bookedMap = seatRepo.getBookedSeats(trainNumber: trainNumber)[
                journeyDate
            ]

        else {
            return false
        }

        for segment in segments {
            guard
                let availableSeats = seatMap[segment],
                let bookedSeats = bookedMap[segment]
            else {
                return false
            }

            let totalConfirmed = availableSeats.filter { $0.hasPrefix("C") }
                .count
            let bookedConfirmed = bookedSeats.filter { $0.hasPrefix("C") }.count

            if bookedConfirmed >= totalConfirmed {
                return false
            }
        }

        return true
    }

    func allocateSeat(
        trainNumber: Int,
        journeyDate: Date,
        seatPreference: String?,
        source: Location,
        destination: Location
    ) -> String {

        let segments = getSegmentsBetween(trainNumber, source, destination)
        if segments.isEmpty { return "INVALID" }

        guard
            let seatMap = seatRepo.getSeats(trainNumber: trainNumber)[
                journeyDate
            ],
            let bookedMap = seatRepo.getBookedSeats(trainNumber: trainNumber)[
                journeyDate
            ]
        else {
            return "FULL"
        }

        
        var allocatedSeat: String?

    
        allocatedSeat = findSeatByPreference(
            segments: segments,
            seatMap: seatMap,
            bookedMap: bookedMap,
            prefix: "C",
            preference: seatPreference
        )
        
        if let allocatedSeat = allocatedSeat {
            for seg in segments {
                seatRepo.addBookedSeat(
                    trainNumber: trainNumber,
                    date: journeyDate,
                    segment: seg,
                    seat: allocatedSeat
                )
            }
        }

        return allocatedSeat != nil ? "\(allocatedSeat!) (CONFIRMED)" : "FULL"
    }
    
    func getAvailability(
        trainNumber: Int,
        journeyDate: Date,
        source: Location,
        destination: Location
    ) -> SeatAvailability? {

        guard let train = trainRepo.getTrain(trainNumber) else { return nil }

        let segments = getSegmentsBetween(trainNumber, source, destination)
        if segments.isEmpty { return nil }

        let totalConfirmed = Int(train.totalConfirmedSeats)

        let bookedByDate =
        seatRepo.getBookedSeats(trainNumber: trainNumber)[journeyDate]
        ?? [:]

        var minFreeConfirmed = totalConfirmed

        for seg in segments {
            let bookedInSegment = bookedByDate[seg] ?? []
            let bookedConfirmed = bookedInSegment.filter { $0.hasPrefix("C") }
                .count
            let freeInSegment = totalConfirmed - bookedConfirmed
            minFreeConfirmed = min(minFreeConfirmed, freeInSegment)
        }

        if minFreeConfirmed < 0 { minFreeConfirmed = 0 }

        let key = compositeKey(trainNumber, journeyDate)

        let racQueue = seatRepo.racQueue(for: key)
        let wlQueue = seatRepo.waitingList(for: key)

        let totalRAC = Int(train.totalRACSeats)
        let totalWL = Int(train.totalWaitingSeats)

        let racAvailable = max(0, totalRAC - racQueue.count)
        let wlAvailable = max(0, totalWL - wlQueue.count)

        return SeatAvailability(
            confirmedAvailable: minFreeConfirmed,
            racAvailable: racAvailable,
            waitingAvailable: wlAvailable
        )
    }

    private func generateConfirmedSeats(_ totalSeats: UInt) -> [String] {
        let positions = ["W", "M", "A"]
        var coach = 1
        var seatNo = 1
        var seats: [String] = []

        for _ in 0..<totalSeats {
            let seat =
            "C\(coach)-\(positions[(seatNo - 1) % positions.count])\(seatNo)"
            seats.append(seat)

            seatNo += 1
            if seatNo > positions.count {
                seatNo = 1
                coach += 1
            }
        }
        return seats
    }

    private func findSeatByPreference(
        segments: [String],
        seatMap: [String: [String]],
        bookedMap: [String: Set<String>],
        prefix: String,
        preference: String?
    ) -> String {

        guard let firstSegment = segments.first, !segments.isEmpty else {
            return "NULL"
        }

        var possibleSeats = Set<String>()

        for seat in seatMap[firstSegment] ?? [] {
            let hasPrefix = seat.hasPrefix(prefix)
            let matchesPreference =
            preference == nil || preference?.lowercased() == "no-preference"
            || seat.contains(preference!.prefix(1).uppercased())
            let notBooked = !(bookedMap[firstSegment] ?? []).contains(seat)

            if hasPrefix && matchesPreference && notBooked {
                possibleSeats.insert(seat)
            }
        }

        for segment in segments {
            let bookedInSegment = bookedMap[segment] ?? []
            let seatsInSegment = seatMap[segment] ?? []

            var validInThisSegment = Set<String>()

            for seat in seatsInSegment {
                let hasPrefix = seat.hasPrefix(prefix)
                let matchesPreference =
                preference == nil
                || preference?.lowercased() == "no-preference"
                || seat.contains(preference!.prefix(1).uppercased())
                let notBooked = !bookedInSegment.contains(seat)

                if hasPrefix && matchesPreference && notBooked {
                    validInThisSegment.insert(seat)
                }
            }

            possibleSeats.formIntersection(validInThisSegment)

            if possibleSeats.isEmpty {
                break
            }
        }

     
        if possibleSeats.isEmpty,
           let pref = preference,
           pref.lowercased() != "no-preference"
        {
            return findSeatByPreference(
                segments: segments,
                seatMap: seatMap,
                bookedMap: bookedMap,
                prefix: prefix,
                preference: nil
            )
        }

        return possibleSeats.first ?? "NULL"
    }

    func getSegmentsBetween(
        _ trainNumber: Int,
        _ source: Location,
        _ destination: Location
    ) -> [String] {

        guard let train = trainRepo.getTrain(trainNumber) else { return [] }
        let stations = trainRepo.getRoutes(train.routeId)

        var segments: [String] = []
        var started = false

        for i in 0..<(stations.count - 1) {
            let from = stations[i]
            let to = stations[i + 1]

            if from.locationId == source.locationId {
                started = true
            }

            if started {
                let key = AppHelper.segmentKey(from: from, to: to)
                segments.append(key)
            }

            if to.locationId == destination.locationId {
                break
            }
        }

        return segments
    }

    private func compositeKey(_ trainNumber: Int, _ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(trainNumber)_\(formatter.string(from: date))"
    }

}
