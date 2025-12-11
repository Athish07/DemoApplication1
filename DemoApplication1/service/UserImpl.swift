import Foundation

final class UserImpl: UserService {
    
    private let userRepo: UserRepoService
    private let bookingService: BookingService
    private let ticketRepo: TicketRepoService
    
    private init(userRepo: UserRepoService, bookingService: BookingService, ticketRepo: TicketRepoService){
        self.userRepo=userRepo
        self.bookingService=bookingService
        self.ticketRepo=ticketRepo
    }
    
  
    static func build(
        userRepo: UserRepoService,
        bookingService: BookingService,
        ticketRepo: TicketRepoService
    ) -> UserService {
        return UserImpl(
            userRepo: userRepo,
            bookingService: bookingService,
            ticketRepo: ticketRepo
        )
    }
    
    func updateProfile(currentUser: User?, name: String, phone: String) throws {

        guard var currentUser else {
            throw UserError.invalidUser
        }

        if !name.isEmpty && !Validation.isValidString(name) {
            throw UserError.invalidName
        }

        if !phone.isEmpty && !Validation.isValidPhone(phone) {
            throw UserError.invalidPhone
        }

        currentUser.userName = name.isEmpty ? currentUser.userName : name
        currentUser.phoneNumber =
            phone.isEmpty ? currentUser.phoneNumber : phone
    }

    func validatePassword(currentUser: User?, oldPassword: String) -> Bool {

        guard
            let currentUser, Validation.isValidString(oldPassword)
        else { return false }

        return currentUser.password == oldPassword
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

        return bookingService.bookTicket(
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
        bookingService.cancelTicket(ticketId: ticketId)
    }

    func getUserBookingHistory(userId: Int) -> [Ticket] {
        bookingService.getUserBookingHistory(userId: userId)
    }

    func viewTicketStatus(ticketId: Int) -> [TicketStatusHistory] {
        ticketRepo.history(for: ticketId)
    }

    func updatePassword(currentUser: User, newPassword: String) {
        userRepo.updatePassword(for: currentUser.userId, with: newPassword)
    }

}
