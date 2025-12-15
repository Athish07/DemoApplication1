import Foundation

class UserImpl: UserService {
    
    private let userRepo: UserRepository
    private let bookingService: BookingService
    private let ticketRepo: TicketRepository
   
    
    private init(
        userRepo: UserRepository,
        bookingService: BookingService,
        ticketRepo: TicketRepository
    
    ){
        self.userRepo=userRepo
        self.bookingService=bookingService
        self.ticketRepo=ticketRepo
    }
    
  
    static func build(
        userRepo: UserRepository,
        bookingService: BookingService,
        ticketRepo: TicketRepository
     
    ) -> UserService {
        return UserImpl(
            userRepo: userRepo,
            bookingService: bookingService,
            ticketRepo: ticketRepo
        )
    }
    
    func updateUserDetails(userId: Int, userName: String, phoneNumber: String) {
        guard var user = userRepo.findById(userId) else { return }
        
        user.updateUserDetails(userName, phoneNumber)
        userRepo.save(user)
        
    }
    
    func changePassword(userId: Int, newPassword: String) {
        guard var user = userRepo.findById(userId) else { return }
        
        user.updatePassword(newPassword)
        userRepo.save(user)
        
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
    
    func findUserById(userId: Int) -> User? {
        return userRepo.findById(userId)
    }
    
    func cancelTicket(ticketId: Int) -> Bool {
        bookingService.cancelTicket(ticketId: ticketId)
    }

    func getUserBookingHistory(userId: Int) -> [Ticket] {
        bookingService.getUserBookingHistory(userId: userId)
    }

    func viewTicketStatus(ticketId: Int) -> [TicketStatusHistory] {
        ticketRepo.ticketHistory(for: ticketId)
    }
    
}
