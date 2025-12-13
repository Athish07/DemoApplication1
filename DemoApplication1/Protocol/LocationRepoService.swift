
protocol LocationRepoService {
    
    func fetchSouceAndIntermediates() -> [Location]
    func fetchDestinations() -> [Location]
    func addLocation(_ location: Location)
    
}
