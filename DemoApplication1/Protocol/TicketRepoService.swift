import Foundation

protocol TicketRepoService {

    func save(_ ticket: Ticket)
    func findByUser(_ userId: Int) -> [Ticket]
    func addHistory(_ ticketId: Int, _ history: TicketStatusHistory)
    func findById(_ ticketId: Int) -> Ticket?
    func history(for ticketId: Int) -> [TicketStatusHistory]
}
