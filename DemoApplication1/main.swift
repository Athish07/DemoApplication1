import Foundation

private func makeSeatManagerService(
    seatRepo: SeatRepository,
    trainRepo: TrainRepository
) -> SeatManagerService {
    return SeatManagerImpl.build(seatRepo: seatRepo, trainRepo: trainRepo)
}

private func makeBookingService(
    seatManager: SeatManagerService,
    seatRepo: SeatRepository,
    ticketRepo: TicketRepository,
) -> BookingService {
    return BookingImpl.build(
        seatManager: seatManager,
        seatRepo: seatRepo,
        ticketRepo: ticketRepo,
    )
}

private func makeUserService(
    userRepo: UserRepository,
    bookingService: BookingService,
) -> UserService {
    return UserImpl.build(
        userRepo: userRepo,
        bookingService: bookingService,
    )
}

private func makeAuthService(
    userRepo: UserRepository
) -> AuthService {
    return AuthServiceImpl.build(userRepo: userRepo)
}

private func makeTrainService(
    trainRepo: TrainRepository,
    seatManager: SeatManagerService
) -> TrainService {
    return TrainImpl.build(
        trainRepo: trainRepo,
        seatManager: seatManager,
        locationService: locationService
    )
}

private func makeLocationService(locationRepo: LocationRepository) -> LocationService {
      return LocationImpl(locationRepo: locationRepo)
}

let userRepo = UserRepositoryImpl.shared
let seatRepo = SeatRepositoryImpl.shared
let ticketRepo = TicketRepositoryImpl.shared
let trainRepo = TrainRepositoryImpl.shared
let locationRepo = LocationRepositoryImpl.shared

let seatManager = makeSeatManagerService(
    seatRepo: seatRepo,
    trainRepo: trainRepo
)

let bookingService = makeBookingService(
    seatManager: seatManager,
    seatRepo: seatRepo,
    ticketRepo: ticketRepo,
)

let userService = makeUserService(
    userRepo: userRepo,
    bookingService: bookingService
)

let authService = makeAuthService(userRepo: userRepo)

let locationService = makeLocationService(locationRepo: locationRepo)

let trainService = makeTrainService(
    trainRepo: trainRepo,
    seatManager: seatManager
)

let controller = AppController(
    userService: userService,
    trainService: trainService,
    authService: authService,
    seatManager: seatManager,
    locationService: locationService
)

let appView = AppView(controller: controller)

print("Railway Ticket Booking System")
print("==============================")
appView.start()

