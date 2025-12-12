import Foundation

struct Validation {
    private init() {}

    private static let minNameLength = 2
    private static let maxNameLength = 100
    private static let minPasswordLength = 6
    private static let maxPasswordLength = 50
    private static let phoneLength = 10
    private static let maxStationNameLength = 50

    public static func isValidString(_ s: String) -> Bool {
        return !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private static let emailRegex =
    "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"

    public static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return isValidString(email) && trimmed.matches(emailRegex)
    }

    private static let phoneRegex = "^[6-9]\\d{9}$"

    public static func isValidPhone(_ phone: String) -> Bool {
        let cleaned = phone.replacingOccurrences(
            of: "[^0-9]",
            with: "",
            options: .regularExpression
        )
        return cleaned.count == phoneLength && cleaned.matches(phoneRegex)
    }

    private static let nameRegex = "^[a-zA-Z\\s.]+$"

    public static func isValidName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return isValidString(name) && trimmed.count >= minNameLength
        && trimmed.count <= maxNameLength && trimmed.matches(nameRegex)
    }

    private static let passwordStrengthRegex = "^(?=.*[a-zA-Z])(?=.*\\d).+$"

    public static func isValidPassword(_ password: String) -> Bool {
        let trimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
        return isValidString(password) && trimmed.count >= minPasswordLength
        && trimmed.count <= maxPasswordLength
        && trimmed.matches(passwordStrengthRegex)
    }

    private static let stationNameRegex = "^[a-zA-Z\\s-]+$"

    public static func isValidStationName(_ stationName: String) -> Bool {
        let trimmed = stationName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        return isValidString(stationName)
        && trimmed.count <= maxStationNameLength
        && trimmed.matches(stationNameRegex)
    }

    public static func isValidUser(_ user: User) -> Bool {
        return isValidName(user.userName) && isValidEmail(user.email)
        && isValidPhone(user.phoneNumber)
    }

    public static func isValidAge(
        _ age: Int,
        minAge: Int = 0,
        maxAge: Int = 120
    ) -> Bool {
        return age >= minAge && age <= maxAge
    }

    public static func isValidGender(_ gender: String) -> Bool {
        let trimmed = gender.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return ["male", "female", "other", "nondisclosure"].contains(trimmed)
    }

    public static func isValidSeatPreference(_ preference: String) -> Bool {
        let trimmed = preference.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return ["window", "middle", "aisle", "no-preference"].contains(trimmed)
    }

    public static func passwordsMatch(_ password1: String, _ password2: String)
    -> Bool
    {
        return password1 == password2
    }

    public static func isValidConfirmation(_ input: String) -> Bool {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return trimmed == "yes" || trimmed == "no"
    }
}

extension String {
    func matches(_ pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: count)
            return regex.firstMatch(in: self, range: range) != nil
        } catch {
            assertionFailure("Invalid regex pattern: \(pattern)")
            return false
        }
    }

}
