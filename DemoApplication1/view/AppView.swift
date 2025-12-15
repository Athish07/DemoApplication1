import Foundation

class AppView {

    private let controller: AppController
   

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
        case 2: showProfile()
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
            let email = AppHelper.readString()
            if email == "0" { return }

            if !Validation.isValidEmail(email) {
                print("Invalid email format. Try again or enter 0 to cancel.")
                continue
            }

            print("Password: ", terminator: "")
            let password = AppHelper.readString()
            if password == "0" { return }

            if controller.login(email: email, password: password) {
                print("Login Success")
            } else {
                print("Invalid username or password. Try again.")
            }
            return
        }
    }

    private func register() {
        print("Enter 0 at any time to go back")

        var name: String
        while true {
            print("Name: ", terminator: "")
            name = AppHelper.readString()
            if name == "0" { return }
            if Validation.isValidName(name) { break }
            print("Invalid name. Try again.")
        }

        var email: String
        while true {
            print("Email: ", terminator: "")
            email = AppHelper.readString()
            if email == "0" { return }
            if Validation.isValidEmail(email) { break }
            print("Invalid email. Try again.")
        }

        var phone: String
        while true {
            print("Phone: ", terminator: "")
            phone = AppHelper.readString()
            if phone == "0" { return }
            if Validation.isValidPhone(phone) { break }
            print("Invalid phone. Try again.")
        }

        var password: String
        while true {
            print("Password: ", terminator: "")
            password = AppHelper.readString()
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
        
        print("Sources: ", terminator: "")
        controller.getSourceAndIntermediateLocations().forEach { location in
            print(location.locationName, terminator: " ")
        }

        print("\nDestinations: ", terminator: "")
        controller.getDestinationLocations().forEach { location in
            print(location.locationName, terminator: " ")
        }
        
        print("\nEnter 0 to go back")

        print("Source: ", terminator: "")
        let source = AppHelper.readString()
        if source == "0" { return }

        print("Destination: ", terminator: "")
        let destination = AppHelper.readString()
        if destination == "0" { return }

        print("Date (dd-MM-yyyy): ", terminator: "")
        let dateStr = AppHelper.readString()
        if dateStr == "0" { return }

        guard let date = DateFormatterHelper.parse(dateStr) else {
            print("Invalid date formate (dd-MM-yyyy) or date is in the past ")
            return
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        if date <= today {
            print("Date should be greater than today's date")
            return
        }
        
        let maxAllowedDate = Calendar.current.date(
            byAdding: .day,
            value: 120,
            to: Date()
        )!
        
        if date > maxAllowedDate {
            print("Date should not be more than 120 days from today")
            return
        }

        let trains = controller.searchTrains(
            source: source,
            destination: destination,
            date: date
        )

        if trains.isEmpty {
            print("No trains found")
            return
        }

        for train in trains {
            controller.initializeTrainSeats(
                trainNumber: train.trainNumber,
                journeyDate: date,
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
                journeyDate: date,
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
        print("Login to proceed with booking")
    }
    
    private func showProfile() {
       
        guard let currentUser = controller.currentUser else {
            return
        }
        
        print("Profile Details: ")
        print("Name: \(currentUser.userName)")
        print("Email: \(currentUser.email)")
        print("phoneNumber: \(currentUser.phoneNumber)")
        
        print(
            "\nIf you want to update the profile details (yes,no): ",
            terminator: ""
        )
        let input = AppHelper.readString()
        
        if input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() == "yes" {
            updateProfile()
        }
    }
    
    private func updateProfile() {
        
        print("---------------------------------")
        print("1. Update UserName and PhoneNumber")
        print("2. Update Password")
        print("---------------------------------")
        print("Enter your choice: ", terminator: "")

        let choice = AppHelper.readInt()

        switch choice {
        case 1:
            updateUserDetails()

        case 2:
            updatePassword()

        default:
            print("Invalid option.")
        }

        
    }
    
    private func updateUserDetails() {
       
        guard let user = controller.currentUser else {
            print("No user logged in.")
            return
        }

        print("------ Update Profile ------")

        
        print("Current Name: \(user.userName)")
        print("Enter new name (press Enter to keep current): ", terminator: "")
        
        var newNameInput = readLine() ?? ""
       
        if newNameInput.isEmpty {
            newNameInput = user.userName
        }
            
        guard Validation.isValidName(newNameInput) else {
            print("Invalid name.")
            return
        }


      
        print("Current Phone Number: \(user.phoneNumber)")
        print(
            "Enter new phone number (press Enter to keep current): ",
            terminator: ""
        )
        
        var newPhoneNumber = readLine() ?? ""
        
        if newPhoneNumber.isEmpty {
            newPhoneNumber = user.phoneNumber
        }
        
        guard Validation.isValidPhone(newPhoneNumber) else {
            print("Invalid phone number.")
            return
        }
        
        controller.updateUserDetails(name: newNameInput, phone: newPhoneNumber)
        print("Updated Successfully.")
            
    }
    
    private func updatePassword() {
        
        guard let user = controller.currentUser else {
            print("No user logged in.")
            return
        }

        print("------ Update Password ------")

        print("Enter old password: ", terminator: "")
        
        guard let oldPassword = readLine(), !oldPassword.isEmpty else {
            print("Invalid input.")
            return
        }

        if oldPassword != user.password {
            print("Incorrect old password.")
            return
        }

        print("Enter new password: ", terminator: "")
        guard let newPassword = readLine(), !newPassword.isEmpty, Validation
            .isValidPassword(newPassword) else {
            print("New password cannot be empty.")
            return
        }

        print("Confirm new password: ", terminator: "")
        guard let confirmPassword = readLine(), confirmPassword == newPassword else {
            print("Passwords do not match.")
            return
        }
       
        controller.changePassword(newPassword: newPassword)
        print("Password updated successfully.")
        
    }

    
    private func searchAndBook() {
        
        print("Sources: ", terminator: "")
        controller.getSourceAndIntermediateLocations().forEach { location in
            print(location.locationName, terminator: " ")
        }

        print("\nDestinations: ", terminator: "")
        controller.getDestinationLocations().forEach { location in
            print(location.locationName, terminator: " ")
        }

        
        print("\nEnter 0 to go back")
        print("Source: ", terminator: "")
        let source = AppHelper.readString()
        if source == "0" { return }

        print("Destination: ", terminator: "")
        let destination = AppHelper.readString()
        if destination == "0" { return }

        print("Date (dd-MM-yyyy): ", terminator: "")
        let dateStr = AppHelper.readString()
        if dateStr == "0" { return }

        guard let date = DateFormatterHelper.parse(dateStr) else {
            print("Invalid date formate (dd-MM-yyyy) or date is in the past ")
            return
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        if date <= today {
            print("Date should be greater than today's date")
            return
        }
        
        let maxAllowedDate = Calendar.current.date(
            byAdding: .day,
            value: 120,
            to: Date()
        )!
        
        if date > maxAllowedDate {
            print("Date should not be more than 120 days from today")
            return
        }
        
        let trains = controller.searchTrains(
            source: source,
            destination: destination,
            date: date
        )
        
        if trains.isEmpty {
            print("No trains found")
            return
        }

        for train in trains {
            controller.initializeTrainSeats(
                trainNumber: train.trainNumber,
                journeyDate: date,
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
                journeyDate: date,
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
        let name = AppHelper.readString()
        if name == "0" { return }

        print("Age (0 to cancel): ", terminator: "")
        let ageValue = safeReadInt()
        if ageValue == 0 { return }
        let age = UInt(ageValue)
        
        if age > 125 {
            
            print("Age should below 120 and above 0")
            return
        }
        
        print("Gender (0 to cancel)")
        print(
            "(male, female, other, nondisclosure) (default is nondisclosure): ",
            terminator: ""
        )
        let genderInput = AppHelper.readString()
        if genderInput == "0" { return }
        let gender =
        Gender(rawValue: genderInput.lowercased()) ?? .nondisclosure

        print("Seat Preference (0 to cancel)")
        print("(window, aisle, middle, any) (default is any): ", terminator: "")
        let prefInput = AppHelper.readString()
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
            journeyDate: date
        ) {
            print(ticket.getDetails())
            print(
                "Source Arrival Time : \(locations[0].departureTime!.formatTimeOnlyIST())"
            )
            print(
                "Destination Departure Time: \(locations[1].arrivalTime!.formatTimeOnlyIST())"
            )
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
        
        print(
            "\nDo you want to track the ticket states? (yes/no):",
            terminator: ""
        )
        let input = AppHelper.readString()
        if input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() == "yes" {
            print("Enter the Ticket ID: ", terminator: "")
            let ticketId = safeReadInt()
            
            let history = controller.ticketStatusHistory(ticketId: ticketId)

            if history.isEmpty {
                print("No status found for that ticket number")
            } else {
                for item in history {
                    print(
                        "\(item.date.formatTimeOnlyIST()) - \(item.status.rawValue)"
                    )
                }
            }
        }
        
    }

    private func safeReadInt(allowZeroAsValid: Bool = false) -> Int {
        while true {
            let str = AppHelper.readString()
            if let value = Int(str) {
                if value == 0 && allowZeroAsValid { return value }
                if value >= 0 { return value }
            }
            print("Invalid number. Try again: ", terminator: "")
        }
    }
}

extension Date {
    
    func formatTimeOnlyIST() -> String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        df.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return df.string(from: self)
    }
}

