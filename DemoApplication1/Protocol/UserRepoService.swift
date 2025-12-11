import Foundation

protocol UserRepoService {

    func save(_ user: User)
    func findByEmail(_ email: String) -> User?
    func getAll() -> [User]
    func updatePassword(for userId: Int, with newPassword: String)
    
}
