import Foundation

protocol UserService {
    func updateUserDetails(userId: Int, userName: String, phoneNumber: String)
    func changePassword(userId: Int, newPassword: String)
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
    ) -> Ticket?
    func cancelTicket(ticketId: Int) -> Bool
    func getUserBookingHistory(userId: Int) -> [Ticket]
    func viewTicketStatus(ticketId: Int) -> [TicketStatusHistory]
    func findUserById(userId: Int) -> User?
}
