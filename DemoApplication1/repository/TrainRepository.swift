import Foundation

class TrainRepository: TrainRepoService {

    private var trains: [Int: Train] = [:]
    private var route: [Int: [Location]] = [:]

    static let shared = TrainRepository()
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

    func addStation(routeId: Int, station: Location) {
        route[routeId, default: []].append(station)
    }

    func getStations(_ routeId: Int) -> [Location] {
        route[routeId] ?? []
    }

    func getTrain(_ trainNumber: Int) -> Train? {
        trains[trainNumber]
    }

    func getAllTrains() -> [Train] {
        Array(trains.values)
    }

    func getStationNames(routeId: Int) -> [String] {
        route[routeId]?.map(\.locationName) ?? []
    }

   
}
