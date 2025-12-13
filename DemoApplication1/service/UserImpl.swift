import Foundation

class UserImpl: UserService {
    
    private let userRepo: UserRepository
    private let bookingService: BookingService
   
    
    private init(
        userRepo: UserRepository,
        bookingService: BookingService,
    
    ){
        self.userRepo=userRepo
        self.bookingService=bookingService
   
    }
    
  
    static func build(
        userRepo: UserRepository,
        bookingService: BookingService,
     
    ) -> UserService {
        return UserImpl(
            userRepo: userRepo,
            bookingService: bookingService,
        )
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
    
}
