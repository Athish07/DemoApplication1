import Foundation

protocol TrainRepoService {
    func save(_ train: Train)
    func findTrains(from source: String, to destination: String, date: Date)
    -> [Train]
    func addRoute(routeId: Int, location: Location)
    func getRoutes(_ routeId: Int) -> [Location]
    func getTrain(_ trainNumber: Int) -> Train?
    func getAllTrains() -> [Train]
    func getRouteNames(routeId: Int) -> [String]
}
