import Foundation

struct DateFormatterHelper {

    private static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone.current
        return df
    }()

    static func parse(_ dateStr: String?) -> Date? {
        guard
            let dateStr = dateStr?.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            !dateStr.isEmpty,
            let date = formatter.date(from: dateStr)
        else {
            return nil
        }

        return Calendar.current.startOfDay(for: date)
    }
}
