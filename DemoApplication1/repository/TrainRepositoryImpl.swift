import Foundation

class TrainRepositoryImpl: TrainRepository {

    private var trains: [Int: Train] = [:]
    private var route: [Int: [Location]] = [:]
    
    static let shared = TrainRepositoryImpl()
    private init() {}

    func save(_ train: Train) {
        trains[train.trainNumber] = train
    }

    func findTrains(
        from source: String,
        to destination: String,
        date: Date
    ) -> [Train] {

        return trains.values.filter { train in
            let routeStations = route[train.routeId] ?? []
            
            if let sourceIndx = routeStations.firstIndex(where: {
                $0.locationName.lowercased() == source.lowercased()
            }),
               let destIdx = routeStations.firstIndex(where: {
                   $0.locationName.lowercased() == destination.lowercased()
               })
            {
                return sourceIndx < destIdx
            }
            return false
            
        }
    }

    func addRoute(routeId: Int, location: Location) {
        route[routeId, default: []].append(location)
    }

    func getRoutes(_ routeId: Int) -> [Location] {
        route[routeId] ?? []
    }

    func getTrain(_ trainNumber: Int) -> Train? {
        trains[trainNumber]
    }

    func getAllTrains() -> [Train] {
        Array(trains.values)
    }

    func getRouteNames(routeId: Int) -> [String] {
        route[routeId]?.map(\.locationName) ?? []
    }

   
}
