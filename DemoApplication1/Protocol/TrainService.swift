import Foundation

protocol TrainService {
    func searchTrains(source: String, destination: String, date: Date)
    -> [Train]
    func getTrain(trainNumber: Int) -> Train?
    func addTrain(_ train: Train)
    func initializeTrainSeats(
        trainNumber: Int,
        journeyDate: Date,
        routeId: Int,
        totalConfirmed: UInt,
        totalRAC: UInt,
        totalWaiting: UInt
    )
    func getSampleRouteChennaiBangalore() -> Int
    func getSampleRouteDelhiMumbai() -> Int
    func findLocationObject(
        train: Train,
        sourceName: String,
        destinationName: String
    ) -> [Location]?

}
