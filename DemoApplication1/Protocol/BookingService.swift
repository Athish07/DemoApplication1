import Foundation

protocol BookingService {
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
}
