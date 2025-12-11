import Foundation

protocol UserService {
    func updateProfile(currentUser: User?, name: String, phone: String) throws
    func validatePassword(currentUser: User?, oldPassword: String) -> Bool
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
    func updatePassword(currentUser: User, newPassword: String)
}
