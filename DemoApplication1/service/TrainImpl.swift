import Foundation

class TrainImpl: TrainService {

    private let trainRepo: TrainRepository
    private let seatManagerService: SeatManagerService
    private let locationService: LocationService

    init(
        trainRepo: TrainRepository,
        seatManagerService: SeatManagerService,
        locationService: LocationService
    ) {
        self.seatManagerService = seatManagerService
        self.trainRepo = trainRepo
        self.locationService = locationService
    }

    private static var routeIdCounter: Int = 1

    static func build(
        trainRepo: TrainRepository,
        seatManager: SeatManagerService,
        locationService: LocationService
    ) -> TrainService {
        return TrainImpl(
            trainRepo: trainRepo,
            seatManagerService: seatManager,
            locationService:  locationService
        )
    }

    func searchTrains(source: String, destination: String, date: Date)
    -> [Train]
    {
        if date >= Calendar.current.startOfDay(for: Date()),
           !source.trimmingCharacters(in: .whitespaces).isEmpty,
           !destination.trimmingCharacters(in: .whitespaces).isEmpty
        {
            return trainRepo.findTrains(
                from: source,
                to: destination,
                date: date
            )
        }
        
        return []


    }

    func getTrain(trainNumber: Int) -> Train? {
        trainRepo.getTrain(trainNumber)
    }

    func addTrain(_ train: Train) {
        trainRepo.save(train)
    }

    func initializeTrainSeats(
        trainNumber: Int,
        journeyDate: Date,
        routeId: Int,
        totalConfirmed: UInt,
        totalRAC: UInt,
        totalWaiting: UInt
    ) {
        seatManagerService.initializeSeatsForTrain(
            trainNumber: trainNumber,
            journeyDate: journeyDate,
            routeId: routeId,
            totalConfirmedSeats: totalConfirmed,
            totalRACSeats: totalRAC,
            totalWaitingSeats: totalWaiting
        )
    }

    func findLocationObject(
        train: Train,
        sourceName: String,
        destinationName: String
    ) -> [Location]? {

        let stations = trainRepo.getRoutes(train.routeId)

        guard
            let source = stations.first(where: {
                $0.locationName.caseInsensitiveCompare(sourceName)
                == .orderedSame
            }),
            let destination = stations.first(where: {
                $0.locationName.caseInsensitiveCompare(destinationName)
                == .orderedSame
            })
        else {
            return nil
        }

        let sourceIndex =
        stations.firstIndex(where: { $0.locationId == source.locationId })
        ?? -1
        let destinationIndex =
        stations.firstIndex(where: {
            $0.locationId == destination.locationId
        }) ?? -1

        guard sourceIndex < destinationIndex else {
            return nil
        }

        return [source, destination]
    }

    func getSampleRouteChennaiBangalore() -> Int {
        let routeId = Self.routeIdCounter
        Self.routeIdCounter += 1

        let location_1 = Location.createOrigin(
            name: "Chennai",
            departureTime: time(6, 0),
            stopType: .source
        )
        addLocationToRoute(routeId: routeId, location: location_1)
        
        let location_2 = Location.createIntermediate(
            name: "Vellore",
            arrivalTime: time(7, 30),
            departureTime: time(7, 45),
            stopType: .intermediate
        )
        addLocationToRoute(routeId: routeId, location: location_2)
        
        let location_3 = Location.createIntermediate(
                name: "Hosur",
                arrivalTime: time(9,15),
                departureTime: time(9,30),
                stopType: .intermediate
            )
        addLocationToRoute(routeId: routeId, location: location_3)
        
        let location_4 = Location
            .createDestination(
                name: "Bangalore",
                arrivalTime: time(10,30),
                stopType: .destination
            )
        addLocationToRoute(routeId: routeId, location: location_4)
        
        return routeId
    }

    func getSampleRouteDelhiMumbai() -> Int {
        let routeId = Self.routeIdCounter   //refers to the current type .
        Self.routeIdCounter += 1
        
        let location1 = Location.createOrigin(
            name: "Delhi",
            departureTime: time(8, 0),
            stopType: .source
        )
        addLocationToRoute(routeId: routeId, location: location1)

        let location2 = Location.createIntermediate(
            name: "Agra",
            arrivalTime: time(10, 30),
            departureTime: time(10, 45),
            stopType: .intermediate
        )
        addLocationToRoute(routeId: routeId, location: location2)

        let location3 = Location.createIntermediate(
            name: "Ujjain",
            arrivalTime: time(19, 0),
            departureTime: time(19, 15),
            stopType: .intermediate
        )
        addLocationToRoute(routeId: routeId, location: location3)

        let location4 = Location.createIntermediate(
            name: "Vadodara",
            arrivalTime: time(20, 30),
            departureTime: time(20, 45),
            stopType: .intermediate
        )
        addLocationToRoute(routeId: routeId, location: location4)

        let location5 = Location.createDestination(
            name: "Mumbai",
            arrivalTime: time(23, 0),
            stopType: .destination
        )
        addLocationToRoute(routeId: routeId, location: location5)

        return routeId
    }
    
    private func addLocationToRoute(
        routeId: Int,
        location: Location
    ) {
        trainRepo.addRoute(routeId: routeId, location: location)
        locationService.addLocation(location)
    }
    
    private func time(_ hour: Int, _ minute: Int) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Kolkata")!
        
        let now = Date()
        let today = calendar.startOfDay(for: now)

        return calendar
            .date(
                bySettingHour: hour,
                minute: minute,
                second: 0,
                of: today
            ) ?? now
    }
    
}
