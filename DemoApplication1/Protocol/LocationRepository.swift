
protocol LocationRepository {
    
    func fetchSouceAndIntermediates() -> [Location]
    func fetchDestinations() -> [Location]
    func addLocation(_ location: Location)
    
}
