class LocationRepository: LocationRepoService {
   
    private var locations: [Location] = []
    
    private init() {}
    static let shared = LocationRepository()
    
    func fetchSouceAndIntermediates() -> [Location] {
        locations
            .filter { $0.stopType == .source || $0.stopType == .intermediate}
    }
    
    func fetchDestinations() -> [Location] {
        locations.filter { $0.stopType == .destination }
    }
    
    func addLocation(_ location: Location) {
        locations.append(location)
    }
    
}
