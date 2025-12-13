class LocationImpl: LocationService {

    private let locationRepo: LocationRepository
    
    init(locationRepo: LocationRepository) {
        self.locationRepo = locationRepo
    }

    func getSourceAndIntermediateLocations() -> [Location] {
        return locationRepo.fetchSouceAndIntermediates()
    }

    func getDestinationLocations() -> [Location] {
        return locationRepo.fetchDestinations()
    }
    
    func addLocation(_ location: Location) {
        locationRepo.addLocation(location)
    }

}

