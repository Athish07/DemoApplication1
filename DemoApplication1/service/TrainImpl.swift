import Foundation

final class TrainImpl: TrainService {

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

        trainRepoService.addStation(routeId: routeId, station: createChennai())
        trainRepoService.addStation(routeId: routeId, station: createVellore())
        trainRepoService.addStation(routeId: routeId, station: createHosur())
        trainRepoService.addStation(
            routeId: routeId,
            station: createBangalore()
        )

        return routeId
    }

    func getSampleRouteDelhiMumbai() -> Int {
        let routeId = Self.routeIdCounter
        Self.routeIdCounter += 1

        trainRepoService.addStation(routeId: routeId, station: createDelhi())
        trainRepoService.addStation(routeId: routeId, station: createAgra())
        trainRepoService.addStation(routeId: routeId, station: createUjjain())
        trainRepoService.addStation(routeId: routeId, station: createVadodara())
        trainRepoService.addStation(routeId: routeId, station: createMumbai())

        return routeId
    }

    func getTrainInfoWithSeats(
        train: Train,
        date: Date,
        source: String,
        destination: String
    ) -> String? {

        var info = "Train Number: \(train.trainNumber)\n"
        info += "Train Name  : \(train.trainName)\n"

        let stations = trainRepoService.getStations(train.routeId)

        guard
            let sourceStation = stations.first(where: {
                $0.locationName.lowercased() == source.lowercased()
            }),
            let destStation = stations.first(where: {
                $0.locationName.lowercased() == destination.lowercased()
            })
        else {
            return nil
        }

        info += "Departure   : \(sourceStation.timeInfo) (\(source))\n"
        info += "Arrival     : \(destStation.timeInfo) (\(destination))\n"
        info +=
        "Route       : \(trainRepoService.getStationNames(routeId: train.routeId))\n"

        initializeTrainSeats(
            trainNumber: train.trainNumber,
            journeyDate: date,
            routeId: train.routeId,
            totalConfirmed: train.totalConfirmedSeats,
            totalRAC: train.totalRACSeats,
            totalWaiting: train.totalWaitingSeats
        )

        let seatMap =
        seatRepoService.getSeats(trainNumber: train.trainNumber)[date]
        ?? [:]
        let bookedMap =
        seatRepoService.getBookedSeats(trainNumber: train.trainNumber)[date]
        ?? [:]

        let srcIndex =
        stations.firstIndex {
            $0.locationName.lowercased() == source.lowercased()
        } ?? 0
        let destIndex =
        stations.firstIndex {
            $0.locationName.lowercased() == destination.lowercased()
        } ?? stations.count - 1

        var minConfirmed = Int.max

        for i in srcIndex..<destIndex {
            let key = AppHelper.segmentKey(
                from: stations[i],
                to: stations[i + 1]
            )

            let allSeats = seatMap[key] ?? []
            let booked = bookedMap[key] ?? []

            let totalConfirmed = allSeats.filter { $0.hasPrefix("C") }.count
            let bookedConfirmed = booked.filter { $0.hasPrefix("C") }.count

            minConfirmed = min(minConfirmed, totalConfirmed - bookedConfirmed)
        }

        let available = max(0, minConfirmed)

        guard available > 0 else {
            info += "\nNo Confirmed Seats Available"
            return info
        }

        info += """
            Seat Availability:
              Confirmed: \(available)
              RAC      : Available
              Waiting  : Available
            """

        return info
    }

    func getStationIndex(routeId: Int, location: Location) -> Int {
        trainRepoService.getStations(routeId)
            .firstIndex(where: { $0.locationId == location.locationId }) ?? -1
    }

    private func createChennai() -> Location {
        Location.createOrigin(name: "Chennai", departureTime: time(6, 0))
    }

    private func createVellore() -> Location {
        Location.createIntermediate(
            name: "Vellore",
            arrivalTime: time(7, 30),
            departureTime: time(7, 45)
        )
    }

    private func createHosur() -> Location {
        Location.createIntermediate(
            name: "Hosur",
            arrivalTime: time(9, 15),
            departureTime: time(9, 30)
        )
    }

    private func createBangalore() -> Location {
        Location.createDestination(name: "Bangalore", arrivalTime: time(10, 30))
    }

    private func createDelhi() -> Location {
        Location.createOrigin(name: "Delhi", departureTime: time(8, 0))
    }

    private func createAgra() -> Location {
        Location.createIntermediate(
            name: "Agra",
            arrivalTime: time(10, 30),
            departureTime: time(10, 45)
        )
    }

    private func createUjjain() -> Location {
        Location.createIntermediate(
            name: "Ujjain",
            arrivalTime: time(19, 0),
            departureTime: time(19, 15)
        )
    }

    private func createVadodara() -> Location {
        Location.createIntermediate(
            name: "Vadodara",
            arrivalTime: time(20, 30),
            departureTime: time(20, 45)
        )
    }

    private func createMumbai() -> Location {
        Location.createDestination(name: "Mumbai", arrivalTime: time(23, 0))
    }

    private func time(_ hour: Int, _ minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        components.second = 0
        return Calendar.current.date(from: components) ?? Date()
    }

}
