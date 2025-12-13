class LocationImpl: LocationService {

    private let locationRepo: LocationRepoService
    
    init(locationRepo: LocationRepoService) {
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

