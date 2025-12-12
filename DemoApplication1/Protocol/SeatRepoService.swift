import Foundation

protocol SeatRepoService {

    func racQueue(for key: String) -> [Ticket]
    func racQueueCount(for key: String) -> Int
    func saveWaitingList(_ ticket: Ticket, for key: String)
    func waitingList(for key: String) -> [Ticket]
    func removeRACSeat(for key: String) -> Ticket?
    func removeWaitingListSeat(for key: String) -> Ticket?
    func saveRACQueue(_ ticket: Ticket, for key: String)
    func getSeats(trainNumber: Int) -> [Date: [String: [String]]]
    func getBookedSeats(trainNumber: Int) -> [Date: [String: Set<String>]]
    func waitingListCount(for key:String) -> Int
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
