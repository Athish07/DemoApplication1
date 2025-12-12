import Foundation

final class AppController {

    private let userService: UserService
    private let trainService: TrainService
    private let authService: AuthService
    private let seatManager: SeatManagerService

    private(set) var currentUser: User?

    init(
        userService: UserService,
        trainService: TrainService,
        authService: AuthService,
        seatManager: SeatManagerService,
    ) {
        self.userService = userService
        self.trainService = trainService
        self.authService = authService
        self.seatManager = seatManager
    }

    private static let maxAdvanceBookingDays: UInt = 120
    private static let minAge: UInt = 1
    private static let maxAge: UInt = 120
    private static let bookingCutOffHours: UInt = 2

    func initializeValues() {

        let train1 = Train(
            trainNumber: 101,
            trainName: "Shatabdi Express",
            routeId: trainService.getSampleRouteChennaiBangalore(),
            totalConfirmedSeats: 3,
            totalRACSeats: 3,
            totalWaitingSeats: 3
        )

        let train2 = Train(
            trainNumber: 102,
            trainName: "Rajdhani Express",
            routeId: trainService.getSampleRouteDelhiMumbai(),
            totalConfirmedSeats: 2,
            totalRACSeats: 2,
            totalWaitingSeats: 6
        )

        trainService.addTrain(train1)
        trainService.addTrain(train2)

        let journeyDate = Calendar.current.startOfDay(for: Date())

        for train in [train1, train2] {
            trainService.initializeTrainSeats(
                trainNumber: train.trainNumber,
                journeyDate: journeyDate,
                routeId: train.routeId,
                totalConfirmed: train.totalConfirmedSeats,
                totalRAC: train.totalRACSeats,
                totalWaiting: train.totalWaitingSeats
            )
        }

        _ = authService.register(
            name: "Athish",
            email: "athish@gmail.com",
            phone: "8148847642",
            password: "athish"
        )
    }

    func login(email: String, password: String) -> Bool {
        guard Validation.isValidEmail(email) else { return false }
        currentUser = authService.login(email: email, password: password)
        return currentUser != nil
    }

    func logout() {
        currentUser = nil
    }
    

    func register(name: String, email: String, phone: String, password: String)
    -> Bool
    {
        guard !authService.isUserExists(email: email) else { return false }
        return authService.register(
            name: name,
            email: email,
            phone: phone,
            password: password
        )
    }

    func searchTrains(source: String, destination: String, date: Date)
    -> [Train]
    {
        trainService.searchTrains(
            source: source,
            destination: destination,
            date: date
        )
    }

    func bookTicket(
        train: Train,
        passengerName: String,
        age: UInt,
        gender: String,
        seatPreference: String,
        source: Location,
        destination: Location,
        journeyDate: Date
    ) -> Ticket? {
        guard let user = currentUser else { return nil }

        return userService.bookTicket(
            user: user,
            train: train,
            passengerName: passengerName,
            age: age,
            gender: gender,
            seatPreference: seatPreference,
            source: source,
            destination: destination,
            journeyDate: journeyDate
        )
    }

    func cancelTicket(ticketId: Int) -> Bool {
        userService.cancelTicket(ticketId: ticketId)
    }

    func bookingHistory() -> [Ticket] {
        guard let user = currentUser else { return [] }
        return userService.getUserBookingHistory(userId: user.userId)
    }

    func getTrain(_ trainNumber: Int) -> Train? {
        trainService.getTrain(trainNumber: trainNumber)
    }

    func findLocationObject(
        train: Train,
        source: String,
        destination: String
    ) -> [Location]? {

        return trainService.findLocationObject(
            train: train,
            sourceName: source,
            destinationName: destination
        )
    }

    func getAvailability(
        trainNumber: Int,
        journeyDate: Date,
        source: Location,
        destination: Location
    ) -> SeatAvailability? {
        seatManager.getAvailability(
            trainNumber: trainNumber,
            journeyDate: journeyDate,
            source: source,
            destination: destination
        )
    }

    func initializeTrainSeats(
        trainNumber: Int,
        journeyDate: Date,
        routeId: Int,
        totalConfirmed: UInt,
        totalRAC: UInt,
        totalWaiting: UInt
    ) {
        trainService.initializeTrainSeats(
            trainNumber: trainNumber,
            journeyDate: journeyDate,
            routeId: routeId,
            totalConfirmed: totalConfirmed,
            totalRAC: totalRAC,
            totalWaiting: totalWaiting
        )
    }
}
