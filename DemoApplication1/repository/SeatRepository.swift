import Foundation

final class SeatRepository: SeatRepoService {

    private var racQueues: [String: [Ticket]] = [:]
    private var waitingLists: [String: [Ticket]] = [:]

    private var trainSeatMap: [Int: [Date: [String: [String]]]] = [:]
    private var bookedSeatsMap: [Int: [Date: [String: Set<String>]]] = [:]

    static let shared = SeatRepository()
    private init() {}

    func racQueueCount(for key: String) -> Int {
        racQueues[key]?.count ?? 0
        
    }
    
    func racQueue(for key: String) -> [Ticket] {
        racQueues[key] ?? []
    }
    
    func removeRACSeat(for key: String) -> Ticket? {
        racQueues[key]?.removeFirst()
    }
    
    func removeWaitingListSeat(for key: String) -> Ticket?
    {
        waitingLists[key]?.removeFirst()
    }
    
    func saveRACQueue(_ ticket: Ticket, for key: String) {
        racQueues[key,default: []].append(ticket)
    }

    func waitingList(for key: String) -> [Ticket] {
        waitingLists[key] ?? []
    }
    
    func waitingListCount(for key:String) -> Int {
        waitingLists[key]?.count ?? 0
    }

    func saveWaitingList(_ ticket: Ticket, for key: String) {
        waitingLists[key,default: []].append(ticket)
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
