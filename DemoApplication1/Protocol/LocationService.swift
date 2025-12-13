protocol LocationService {
    
    func getSourceAndIntermediateLocations() -> [Location]
    func getDestinationLocations() -> [Location]
    func addLocation(_ location: Location)
    
}
