import Foundation

struct Ticket {
    let ticketId: Int
    let pnr: String
    let trainNumber: Int
    let trainName: String
    let userId: Int
    let userName: String
    let age: UInt
    let gender: String
    let seatPreference: String
    var allocatedSeat: String
    let source: Location
    let destination: Location
    let dateOfJourney: Date
    var ticketStatus: TicketStatus
    let bookingDate: Date

    private static var nextTicketId: Int = 1

    init(
        trainNumber: Int,
        trainName: String,
        userId: Int,
        userName: String,
        age: UInt,
        gender: String,
        seatPreference: String,
        allocatedSeat: String,
        source: Location,
        destination: Location,
        dateOfJourney: Date,
        ticketStatus: TicketStatus
    ) {
        self.ticketId = Self.nextTicketId
        Self.nextTicketId += 1
        self.trainNumber = trainNumber
        self.trainName = trainName
        self.userId = userId
        self.userName = userName
        self.age = age
        self.gender = gender
        self.seatPreference = seatPreference
        self.allocatedSeat = allocatedSeat
        self.source = source
        self.destination = destination
        self.dateOfJourney = dateOfJourney
        self.ticketStatus = ticketStatus
        self.bookingDate = Date()
        self.pnr = Self.generatePnr()
    }

    mutating func updateTicketStatus(_ newStatus: TicketStatus) {
        self.ticketStatus = newStatus
    }

    mutating func updateAllocatedSeat(_ newSeat: String) {
        self.allocatedSeat = newSeat
    }
    
    func getDetails() -> String {
        return """
            PNR: \(pnr)
            Ticket ID: \(ticketId)
            Passenger: \(userName) | Age: \(age) | Gender: \(gender)
            Train: \(trainName) (\(trainNumber))
            Route Segment: \(source.locationName) -> \(destination.locationName)
            Journey Date: \(dateOfJourney.formatToIST())
            Seat Preference: \(seatPreference)
            Allocated Seat: \(allocatedSeat)
            Status: \(ticketStatus)
            Booked on: \(bookingDate)
            """
    }

    func getShortDetails() -> String {
        return
            "Pnr: \(pnr), Journey Date: \(dateOfJourney), TrainName: \(trainName)) , Status: \(ticketStatus)"
    }

    private static func generatePnr() -> String {
        var generator = SystemRandomNumberGenerator()
        let random64 = generator.next()
        return String(
            String(random64 % 1_000_000, radix: 36).uppercased().prefix(6)
        )
    }
}

extension Date {
    func formatToIST() -> String {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy HH:mm"
        df.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return df.string(from: self)
    }
}
