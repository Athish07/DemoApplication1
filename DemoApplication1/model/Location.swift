import Foundation

struct Location {
     let locationId: Int
     let locationName: String
     let arrivalTime: Date?
     let departureTime: Date?
    let stopType: StopType

    private static var nextId: Int = 1

    public static func createOrigin(name: String, departureTime: Date, stopType: StopType)
        -> Location
    {
        return Location(
            name: name,
            arrivalTime: nil,
            departureTime: departureTime,
            stopType: stopType
        )
    }

    public static func createDestination(name: String, arrivalTime: Date, stopType: StopType)
        -> Location
    {
        return Location(
            name: name,
            arrivalTime: arrivalTime,
            departureTime: nil,
            stopType: stopType
        )
    }

    public static func createIntermediate(
        name: String,
        arrivalTime: Date,
        departureTime: Date,
        stopType: StopType
    ) -> Location {
        return Location(
            name: name,
            arrivalTime: arrivalTime,
            departureTime: departureTime,
            stopType: stopType
        )
    }

    public init(name: String, arrivalTime: Date?, departureTime: Date?, stopType: StopType) {
        self.locationId = Self.nextId
        Self.nextId += 1
        self.locationName = name
        self.arrivalTime = arrivalTime
        self.departureTime = departureTime
        self.stopType = stopType
    }

    public var isOriginStation: Bool {
        arrivalTime == nil && departureTime != nil
    }

    public var isDestinationStation: Bool {
        departureTime == nil && arrivalTime != nil
    }

    public var timeInfo: String {

        switch (arrivalTime, departureTime) {
        case (nil, let dep?):
            return "Departure: \(dep.formatted(.dateTime.hour().minute()))"
        case (let arr?, nil):
            return "Arrival: \(arr.formatted(.dateTime.hour().minute()))"
        case (let arr?, let dep?):
            return
                "Arr: \(arr.formatted(.dateTime.hour().minute())) | Dep: \(dep.formatted(.dateTime.hour().minute()))"
        default:
            return "No times"
        }
    }
    
}
