class UserRepositoryImpl: UserRepository {

    private var users: [Int: User] = [:]

    static let shared = UserRepositoryImpl()
    private init() {}

    func save(_ user: User) {
        users[user.userId] = user
    }

    func findByEmail(_ email: String) -> User? {
        users.values.first { $0.email == email }
    }

    func getAll() -> [User] {
        Array(users.values)
    }
    
    func updatePassword(for userId: Int, with newPassword: String) {
        users[userId]?.password = newPassword
    }
    
}
