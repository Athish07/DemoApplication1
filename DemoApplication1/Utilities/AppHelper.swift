import Foundation

struct AppHelper {

    static func readInt() -> Int {
        while true {
            if let line = readLine(),
               let value = Int(
                line.trimmingCharacters(in: .whitespacesAndNewlines)
               )
            {
                return value
            }
            print("Invalid number. Try again: ", terminator: "")
        }
    }

    static func readString() -> String {
        return (readLine() ?? "").trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }
    
}

extension AppHelper {
    
    static func segmentKey(from: Location, to: Location) -> String {
        "\(from.locationName)-\(to.locationName)"
    }
}
