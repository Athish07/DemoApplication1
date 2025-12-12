class AuthServiceImpl: AuthService {

    private let userRepoService: UserRepoService
    
    private init(userRepoService: UserRepoService) {
        self.userRepoService = userRepoService
    }
    
    static func build(
        userRepo: UserRepoService
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

        userRepoService.save(user)
        return true
    }

    func login(email: String, password: String) -> User? {
        if let user = userRepoService.findByEmail(email.lowercased()) {
            return user.password == password ? user : nil
        }
        
        return nil

    }

    func isUserExists(email: String) -> Bool {
        userRepoService.findByEmail(email.lowercased()) != nil
    }
}
