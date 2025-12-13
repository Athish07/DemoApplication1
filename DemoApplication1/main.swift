import Foundation

private func makeSeatManagerService(
    seatRepo: SeatRepoService,
    trainRepo: TrainRepoService
) -> SeatManagerService {
    return SeatManagerImpl.build(seatRepo: seatRepo, trainRepo: trainRepo)
}

private func makeBookingService(
    seatManager: SeatManagerService,
    seatRepo: SeatRepoService,
    ticketRepo: TicketRepoService,
    trainRepo: TrainRepoService
) -> BookingService {
    return BookingImpl.build(
        seatManager: seatManager,
        seatRepo: seatRepo,
        ticketRepo: ticketRepo,
        trainRepo: trainRepo
    )
}

private func makeUserService(
    userRepo: UserRepoService,
    bookingService: BookingService,
    ticketRepo: TicketRepoService
) -> UserService {
    return UserImpl.build(
        userRepo: userRepo,
        bookingService: bookingService,
        ticketRepo: ticketRepo
    )
}

private func makeAuthService(
    userRepo: UserRepoService
) -> AuthService {
    return AuthServiceImpl.build(userRepo: userRepo)
}

private func makeTrainService(
    trainRepo: TrainRepoService,
    seatRepo: SeatRepoService,
    seatManager: SeatManagerService
) -> TrainService {
    return TrainImpl.build(
        trainRepo: trainRepo,
        seatRepo: seatRepo,
        seatManager: seatManager,
        locationService: locationService
    )
}

private func makeLocationService(locationRepo: LocationRepoService) -> LocationService {
      return LocationImpl(locationRepo: locationRepo)
}

let userRepo = UserRepository.shared
let seatRepo = SeatRepository.shared
let ticketRepo = TicketRepository.shared
let trainRepo = TrainRepository.shared
let locationRepo = LocationRepository.shared

let seatManager = makeSeatManagerService(
    seatRepo: seatRepo,
    trainRepo: trainRepo
)

let bookingService = makeBookingService(
    seatManager: seatManager,
    seatRepo: seatRepo,
    ticketRepo: ticketRepo,
    trainRepo: trainRepo
)

let userService = makeUserService(
    userRepo: userRepo,
    bookingService: bookingService,
    ticketRepo: ticketRepo
)

let authService = makeAuthService(userRepo: userRepo)

let locationService = makeLocationService(locationRepo: locationRepo)

let trainService = makeTrainService(
    trainRepo: trainRepo,
    seatRepo: seatRepo,
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

