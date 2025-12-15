import Foundation

final class TicketRepositoryImpl: TicketRepository {

    private final var tickets: [Int: Ticket] = [:]
    private final var ticketHistory: [Int: [TicketStatusHistory]] = [:]

    static let shared = TicketRepositoryImpl()
    private init() {}

    func save(_ ticket: Ticket) {
        tickets[ticket.ticketId] = ticket
    }

    func findByUser(_ userId: Int) -> [Ticket] {
        tickets.values.filter { $0.userId == userId }
    }
    
    func findById(_ ticketId: Int) -> Ticket? {
        tickets[ticketId]
    }

    func addHistory(_ ticketId: Int, _ history: TicketStatusHistory) {
        ticketHistory[ticketId, default: []].append(history)
    }

    func ticketHistory(for ticketId: Int) -> [TicketStatusHistory] {
        ticketHistory[ticketId] ?? []
    }
}
