import Foundation

struct User {

    let userId: Int
    var userName: String
    var email: String
    var password: String
    var phoneNumber: String

    private static var nextUserId: Int = 1

    init(userName: String, email: String, password: String, phoneNumber: String)
    {
        self.userId = Self.nextUserId
        Self.nextUserId += 1
        self.userName = userName
        self.email = email
        self.password = password
        self.phoneNumber = phoneNumber
    }
    
    mutating func updateUserDetails(_ newName: String, _ phoneNumber: String) {
        self.userName = newName
        self.phoneNumber = phoneNumber
    }
    
    mutating func updatePassword(_ password: String) {
        self.password = password
    }
    
}
