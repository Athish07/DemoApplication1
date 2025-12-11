import Foundation

final class SeatRepository: SeatRepoService {

    private var racQueues: [String: [Ticket]] = [:]
    private var waitingLists: [String: [Ticket]] = [:]

    private var trainSeatMap: [Int: [Date: [String: [String]]]] = [:]
    private var bookedSeatsMap: [Int: [Date: [String: Set<String>]]] = [:]

    static let shared = SeatRepository()
    private init() {}

    func racQueue(for key: String) -> [Ticket] {
        racQueues[key] ?? []
    }

    func saveRACQueue(_ queue: [Ticket], for key: String) {
        racQueues[key] = queue
    }

    func waitingList(for key: String) -> [Ticket] {
        waitingLists[key] ?? []
    }

    func saveWaitingList(_ list: [Ticket], for key: String) {
        waitingLists[key] = list
    }

    func getSeats(trainNumber: Int) -> [Date: [String: [String]]] {
        trainSeatMap[trainNumber] ?? [:]
    }

    func getBookedSeats(trainNumber: Int) -> [Date: [String: Set<String>]] {
        bookedSeatsMap[trainNumber] ?? [:]
    }

    func addBookedSeat(
        trainNumber: Int,
        date: Date,
        segment: String,
        seat: String
    ) {
        var allDates = bookedSeatsMap[trainNumber] ?? [:]
        var dayMap = allDates[date] ?? [:]

        dayMap[segment, default: Set<String>()].insert(seat)

        allDates[date] = dayMap
        bookedSeatsMap[trainNumber] = allDates
    }
    func updateBookedSeats(
        trainNumber: Int,
        updatedMap: [Date: [String: Set<String>]]
    ) {
        bookedSeatsMap[trainNumber] = updatedMap
    }

    func ensureSeatsGenerated(
        trainNumber: Int,
        date: Date,
        segmentSeats: [String: [String]]
    ) {
        var trainDatesMap = trainSeatMap[trainNumber] ?? [:]
        var dateMap = trainDatesMap[date] ?? [:]

        for (segment, seats) in segmentSeats {
            if dateMap[segment] == nil {
                dateMap[segment] = seats
            }
        }

        trainDatesMap[date] = dateMap
        trainSeatMap[trainNumber] = trainDatesMap

        var bookedDatesMap = bookedSeatsMap[trainNumber] ?? [:]
        var bookedDateMap = bookedDatesMap[date] ?? [:]

        for (segment, _) in segmentSeats {
            if bookedDateMap[segment] == nil {
                bookedDateMap[segment] = Set<String>()
            }
        }

        bookedDatesMap[date] = bookedDateMap
        bookedSeatsMap[trainNumber] = bookedDatesMap
    }

}
