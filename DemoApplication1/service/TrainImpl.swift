import Foundation

class TrainImpl: TrainService {

    private let trainRepoService: TrainRepoService
    private let seatRepoService: SeatRepoService
    private let seatManagerService: SeatManagerService

    init(
        trainRepoService: TrainRepoService,
        seatRepoService: SeatRepoService,
        seatManagerService: SeatManagerService
    ) {
        self.seatManagerService = seatManagerService
        self.trainRepoService = trainRepoService
        self.seatRepoService = seatRepoService
    }

    private static var routeIdCounter: Int = 1

    static func build(
        trainRepo: TrainRepoService,
        seatRepo: SeatRepoService,
        seatManager: SeatManagerService
    ) -> TrainService {
        return TrainImpl(
            trainRepoService: trainRepo,
            seatRepoService: seatRepo,
            seatManagerService: seatManager
        )
    }

    func searchTrains(source: String, destination: String, date: Date)
    -> [Train]
    {
        if date >= Calendar.current.startOfDay(for: Date()),
           !source.trimmingCharacters(in: .whitespaces).isEmpty,
           !destination.trimmingCharacters(in: .whitespaces).isEmpty
        {
            return trainRepoService.findTrains(
                from: source,
                to: destination,
                date: date
            )
        }
        
        return []


    }

    func getTrain(trainNumber: Int) -> Train? {
        trainRepoService.getTrain(trainNumber)
    }

    func addTrain(_ train: Train) {
        trainRepoService.save(train)
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

        let stations = trainRepoService.getStations(train.routeId)

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

        trainRepoService
            .addStation(
                routeId: routeId,
                station: Location
                    .createOrigin(name: "Chennai", departureTime: time(6, 0))
            )
        
        trainRepoService
            .addStation(
                routeId: routeId,
                station: Location
                    .createIntermediate(
                        name: "Vellore",
                        arrivalTime: time(7, 30),
                        departureTime: time(7, 45)
                    )
            )
        
        trainRepoService
            .addStation(
                routeId: routeId,
                station: Location
                    .createIntermediate(
                        name: "Hosur",
                        arrivalTime: time(9,15),
                        departureTime: time(9,30)
                    )
            )
        
        trainRepoService
            .addStation(
                routeId: routeId,
                station: Location
                    .createDestination(
                        name: "Bangalore",
                        arrivalTime: time(10,30)
                    )
            )

        return routeId
    }

    func getSampleRouteDelhiMumbai() -> Int {
        let routeId = Self.routeIdCounter   //refers to the current type .
        Self.routeIdCounter += 1

        trainRepoService
            .addStation(
                routeId: routeId,
                station: Location
                    .createOrigin(name: "Delhi", departureTime: time(8, 0))
            )
        trainRepoService
            .addStation(routeId: routeId, station: Location.createIntermediate(
                name: "Agra",
                arrivalTime: time(10, 30),
                departureTime: time(10, 45)
            ))
        trainRepoService
            .addStation(routeId: routeId, station: Location.createIntermediate(
                name: "Ujjain",
                arrivalTime: time(19, 0),
                departureTime: time(19, 15)
            ))
        trainRepoService
            .addStation(routeId: routeId, station: Location.createIntermediate(
                name: "Vadodara",
                arrivalTime: time(20, 30),
                departureTime: time(20, 45)
            ))
        trainRepoService
            .addStation(
                routeId: routeId,
                station:  Location
                    .createDestination(name: "Mumbai", arrivalTime: time(23, 0))
            )

        return routeId
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
