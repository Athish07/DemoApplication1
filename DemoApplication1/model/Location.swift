import Foundation

public struct Location {
    public let locationId: Int
    public let locationName: String
    public let arrivalTime: Date?
    public let departureTime: Date?

    private static var nextId: Int = 1

    public static func createOrigin(name: String, departureTime: Date)
        -> Location
    {
        return Location(
            name: name,
            arrivalTime: nil,
            departureTime: departureTime
        )
    }

    public static func createDestination(name: String, arrivalTime: Date)
        -> Location
    {
        return Location(
            name: name,
            arrivalTime: arrivalTime,
            departureTime: nil
        )
    }

    public static func createIntermediate(
        name: String,
        arrivalTime: Date,
        departureTime: Date
    ) -> Location {
        return Location(
            name: name,
            arrivalTime: arrivalTime,
            departureTime: departureTime
        )
    }

    public init(name: String, arrivalTime: Date?, departureTime: Date?) {
        self.locationId = Self.nextId
        Self.nextId += 1
        self.locationName = name
        self.arrivalTime = arrivalTime
        self.departureTime = departureTime
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

    public var effectiveTime: Date? {
        departureTime ?? arrivalTime
    }
}
