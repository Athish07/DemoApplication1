import Foundation

protocol UserRepository {

    func save(_ user: User)
    func findByEmail(_ email: String) -> User?
    func findById(_ id: Int) -> User?
    
}
