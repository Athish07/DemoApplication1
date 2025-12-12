import Foundation

protocol TrainRepoService {
    func save(_ train: Train)
    func findTrains(from source: String, to destination: String, date: Date)
    -> [Train]
    func addStation(routeId: Int, station: Location)
    func getStations(_ routeId: Int) -> [Location]
    func getTrain(_ trainNumber: Int) -> Train?
    func getAllTrains() -> [Train]
    func getStationNames(routeId: Int) -> [String]
}
