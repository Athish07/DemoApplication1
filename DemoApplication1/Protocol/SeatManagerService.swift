import Foundation

protocol SeatManagerService {

    func initializeSeatsForTrain(
        trainNumber: Int,
        journeyDate: Date,
        routeId: Int,
        totalConfirmedSeats: UInt,
        totalRACSeats: UInt,
        totalWaitingSeats: UInt
    )

    func isConfirmedSeatAvailable(
        trainNumber: Int,
        journeyDate: Date,
        source: Location,
        destination: Location
    ) -> Bool

    func allocateSeat(
        trainNumber: Int,
        journeyDate: Date,
        seatPreference: String?,
        source: Location,
        destination: Location
    ) -> String

    func getSegmentsBetween(
        _ trainNumber: Int,
        _ source: Location,
        _ destination: Location
    ) -> [String]

    func getAvailability(
        trainNumber: Int,
        journeyDate: Date,
        source: Location,
        destination: Location
    ) -> SeatAvailability?

}
