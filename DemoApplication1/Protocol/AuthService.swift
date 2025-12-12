protocol AuthService {
    func register(name: String, email: String, phone: String, password: String)
    -> Bool
    func login(email: String, password: String) -> User?
    func isUserExists(email: String) -> Bool
}
