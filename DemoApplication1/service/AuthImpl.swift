class AuthServiceImpl: AuthService {

    private let userRepo: UserRepository
    
    private init(userRepoService: UserRepository) {
        self.userRepo = userRepoService
    }
    
    static func build(
        userRepo: UserRepository
    ) -> AuthService {
        return AuthServiceImpl(userRepoService: userRepo)
    }
    
    
    func register(name: String, email: String, phone: String, password: String)
    -> Bool
    {
        let user = User(
            userName: name,
            email: email.lowercased(),
            password: password,
            phoneNumber: phone
        )

        guard Validation.isValidUser(user) else {
            return false
        }

        userRepo.save(user)
        return true
    }

    func login(email: String, password: String) -> User? {
        if let user = userRepo.findByEmail(email.lowercased()) {
            return user.password == password ? user : nil
        }
        
        return nil

    }

    func isUserExists(email: String) -> Bool {
        userRepo.findByEmail(email.lowercased()) != nil
    }
}
