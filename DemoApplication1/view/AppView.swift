import Foundation

final class AppView {

    private let controller: AppController
    private let input = AppHelper()

    init(controller: AppController) {
        self.controller = controller
    }

    func start() {
        controller.initializeValues()

        while true {
            if controller.currentUser == nil {
                showPublicMenu()
            } else {
                showAuthorizedMenu()
            }
        }
    }

    private func showPublicMenu() {
        print("")
        print("===== Railway Ticket Booking System =====")
        print("1. Search Trains")
        print("2. Login")
        print("3. Register")
        print("4. Exit")
        print("----------------------------------------")
        print("Enter your choice: ", terminator: "")

        let choice = safeReadInt(allowZeroAsValid: true)

        switch choice {
        case 1: searchTrains()
        case 2: login()
        case 3: register()
        case 4: exit(0)
        default: print("Invalid choice")
        }
    }

    private func showAuthorizedMenu() {
        guard let user = controller.currentUser else { return }

        print("")
        print("===== Welcome, \(user.userName) =====")
        print("1. Search and Book")
        print("2. View Profile")
        print("3. Cancel Ticket")
        print("4. Booking History")
        print("5. Logout")
        print("----------------------------------------")
        print("Enter your choice: ", terminator: "")

        let choice = safeReadInt(allowZeroAsValid: true)

        switch choice {
        case 1: searchAndBook()
        case 2: print(user)
        case 3: cancelTicket()
        case 4: showHistory()
        case 5: controller.logout()
        default: print("Invalid choice")
        }
    }

    private func login() {
        print("Enter 0 to go back")

        while true {

            print("Email: ", terminator: "")
            let email = input.readString()
            if email == "0" { return }

            if !Validation.isValidEmail(email) {
                print("Invalid email format. Try again or enter 0 to cancel.")
                continue
            }

            print("Password: ", terminator: "")
            let password = input.readString()
            if password == "0" { return }

            if controller.login(email: email, password: password) {
                print("Login Success")
            } else {
                print("Login Failed")
            }
            return
        }
    }

    private func register() {
        print("Enter 0 at any time to go back")

        var name: String
        while true {
            print("Name: ", terminator: "")
            name = input.readString()
            if name == "0" { return }
            if Validation.isValidName(name) { break }
            print("Invalid name. Try again.")
        }

        var email: String
        while true {
            print("Email: ", terminator: "")
            email = input.readString()
            if email == "0" { return }
            if Validation.isValidEmail(email) { break }
            print("Invalid email. Try again.")
        }

        var phone: String
        while true {
            print("Phone: ", terminator: "")
            phone = input.readString()
            if phone == "0" { return }
            if Validation.isValidPhone(phone) { break }
            print("Invalid phone. Try again.")
        }

        var password: String
        while true {
            print("Password: ", terminator: "")
            password = input.readString()
            if password == "0" { return }
            if Validation.isValidPassword(password) { break }
            print("Invalid password. Try again.")
        }

        if controller.register(
            name: name,
            email: email,
            phone: phone,
            password: password
        ) {
            print("Registration Success")
        } else {
            print("Registration Failed")
        }
    }

    private func searchTrains() {
        print("Enter 0 to go back")

        print("Source: ", terminator: "")
        let source = input.readString()
        if source == "0" { return }

        print("Destination: ", terminator: "")
        let destination = input.readString()
        if destination == "0" { return }

        print("Date (dd-MM-yyyy): ", terminator: "")
        let dateStr = input.readString()
        if dateStr == "0" { return }

        guard let date = DateFormatterHelper.parse(dateStr) else {
            print("Invalid date format")
            return
        }

        let normalizedDate = Calendar.current.startOfDay(for: date)

        let trains = controller.searchTrains(
            source: source,
            destination: destination,
            date: normalizedDate
        )

        if trains.isEmpty {
            print("No trains found")
            return
        }

        for train in trains {
            controller.initializeTrainSeats(
                trainNumber: train.trainNumber,
                journeyDate: normalizedDate,
                routeId: train.routeId,
                totalConfirmed: train.totalConfirmedSeats,
                totalRAC: train.totalRACSeats,
                totalWaiting: train.totalWaitingSeats
            )

            if let locations = controller.findLocationObject(
                train: train,
                source: source,
                destination: destination
            ),
                locations.count == 2,
                let availability = controller.getAvailability(
                    trainNumber: train.trainNumber,
                    journeyDate: normalizedDate,
                    source: locations[0],
                    destination: locations[1]
                )
            {
                print("----------------------------------------")
                print("Train: \(train.trainName) (\(train.trainNumber))")
                print("Start Station: \(locations[0].locationName) ")
                print("End Station:  \(locations[1].locationName) ")
                print("Confirmed Available: \(availability.confirmedAvailable)")
                print("RAC Available: \(availability.racAvailable)")
                print("Waiting Available: \(availability.waitingAvailable)")
                print("----------------------------------------")
            }
        }
    }

    private func searchAndBook() {
        print("Enter 0 to go back")

        print("Source: ", terminator: "")
        let source = input.readString()
        if source == "0" { return }

        print("Destination: ", terminator: "")
        let destination = input.readString()
        if destination == "0" { return }

        print("Date (dd-MM-yyyy): ", terminator: "")
        let dateStr = input.readString()
        if dateStr == "0" { return }

        guard let date = DateFormatterHelper.parse(dateStr) else {
            print("Invalid date")
            return
        }

        let normalizedDate = Calendar.current.startOfDay(for: date)

        let trains = controller.searchTrains(
            source: source,
            destination: destination,
            date: normalizedDate
        )

        if trains.isEmpty {
            print("No trains found")
            return
        }

        for train in trains {
            controller.initializeTrainSeats(
                trainNumber: train.trainNumber,
                journeyDate: normalizedDate,
                routeId: train.routeId,
                totalConfirmed: train.totalConfirmedSeats,
                totalRAC: train.totalRACSeats,
                totalWaiting: train.totalWaitingSeats
            )

            if let locations = controller.findLocationObject(
                train: train,
                source: source,
                destination: destination
            ),
                locations.count == 2,
                let availability = controller.getAvailability(
                    trainNumber: train.trainNumber,
                    journeyDate: normalizedDate,
                    source: locations[0],
                    destination: locations[1]
                )
            {
                print("----------------------------------------")
                print("Train: \(train.trainName) (\(train.trainNumber))")
                print("Start Station: \(locations[0].locationName) ")
                print("End Station:  \(locations[1].locationName) ")
                print("Confirmed Available: \(availability.confirmedAvailable)")
                print("RAC Available: \(availability.racAvailable)")
                print("Waiting Available: \(availability.waitingAvailable)")
                print("----------------------------------------")
            }
        }

        print("Enter Train Number (0 to go back): ", terminator: "")
        let trainNo = safeReadInt()
        if trainNo == 0 { return }

        guard let train = controller.getTrain(trainNo) else {
            print("Invalid Train")
            return
        }

        print("Passenger Name (0 to cancel): ", terminator: "")
        let name = input.readString()
        if name == "0" { return }

        print("Age (0 to cancel): ", terminator: "")
        let ageValue = safeReadInt()
        if ageValue == 0 { return }
        let age = UInt(ageValue)

        print("Gender (0 to cancel)")
        print(
            "(male, female, other, nondisclosure) (default is nondisclosure): ",
            terminator: ""
        )
        let genderInput = input.readString()
        if genderInput == "0" { return }
        let gender =
            Gender(rawValue: genderInput.lowercased()) ?? .nondisclosure

        print("Seat Preference (0 to cancel)")
        print("(window, aisle, middle, any) (default is any): ", terminator: "")
        let prefInput = input.readString()
        if prefInput == "0" { return }
        let preference =
            SeatPreference(rawValue: prefInput.lowercased()) ?? .any

        guard
            let locations = controller.findLocationObject(
                train: train,
                source: source,
                destination: destination
            ),
            locations.count == 2
        else {
            print("Error in route selection")
            return
        }

        if let ticket = controller.bookTicket(
            train: train,
            passengerName: name,
            age: age,
            gender: gender.rawValue,
            seatPreference: preference.rawValue,
            source: locations[0],
            destination: locations[1],
            journeyDate: normalizedDate
        ) {
            print(ticket.getDetails())
        } else {
            print("Booking Failed")
        }
    }

    private func cancelTicket() {
        let history = controller.bookingHistory()

        if history.isEmpty {
            print("No bookings found")
            return
        }

        for (index, ticket) in history.enumerated() {
            print("\(index + 1). \(ticket.getShortDetails())")
        }

        print("Choose ticket (0 to go back): ", terminator: "")
        let choice = safeReadInt()
        if choice == 0 { return }

        if choice < 1 || choice > history.count {
            print("Invalid selection")
            return
        }

        if controller.cancelTicket(ticketId: history[choice - 1].ticketId) {
            print("Ticket Cancelled")
        } else {
            print("Cancellation Failed")
        }
    }

    private func showHistory() {
        let history = controller.bookingHistory()

        if history.isEmpty {
            print("No history found")
            return
        }

        for ticket in history {
            print(ticket.getDetails())
        }
    }

    private func safeReadInt(allowZeroAsValid: Bool = false) -> Int {
        while true {
            let str = input.readString()
            if let value = Int(str) {
                if value == 0 && allowZeroAsValid { return value }
                if value >= 0 { return value }
            }
            print("Invalid number. Try again: ", terminator: "")
        }
    }
}
