import Foundation

protocol SeatRepoService {

    func racQueue(for key: String) -> [Ticket]
    func saveWaitingList(_ list: [Ticket], for key: String)
    func waitingList(for key: String) -> [Ticket]
    func saveRACQueue(_ queue: [Ticket], for key: String)
    func getSeats(trainNumber: Int) -> [Date: [String: [String]]]
    func getBookedSeats(trainNumber: Int) -> [Date: [String: Set<String>]]
    func addBookedSeat(
        trainNumber: Int,
        date: Date,
        segment: String,
        seat: String
    )
    func ensureSeatsGenerated(
        trainNumber: Int,
        date: Date,
        segmentSeats: [String: [String]]
    )
    func updateBookedSeats(
        trainNumber: Int,
        updatedMap: [Date: [String: Set<String>]]
    )

}
