import Foundation
import Combine
import CoreLocation

enum GeoDataError: Error {
    case permissionsDisabled
}

protocol GeoDataUseCaseProtocol {
    func tryListeningLocations() -> AnyPublisher<CLLocation, Error>
    func stopListeningLocations()
}

protocol GeoDataRepositoryProtocol {
    func requestLocationsIfPossible() -> AnyPublisher<CLLocation, Error>
    func stopListeningLocations()
}

final class GeoDataUseCase: GeoDataUseCaseProtocol {

    private let repository: GeoDataRepositoryProtocol
    private var lastLocation: CLLocation?

    init(repository: GeoDataRepositoryProtocol = GeoDataRepository()) {
        self.repository = repository
    }

    func tryListeningLocations() -> AnyPublisher<CLLocation, Error> {
        lastLocation = nil

        return repository
            .requestLocationsIfPossible()
            .filter { [weak self] newLocation in
                guard let self = self else {
                    return false
                }

                if let lastLocation = self.lastLocation {
                    if lastLocation.distance(from: newLocation) > 100 {
                        log("💬 100 Meters Done")
                        self.lastLocation = newLocation
                        return true
                    }
                    return false
                } else {
                    self.lastLocation = newLocation
                    return true
                }
            }
            .eraseToAnyPublisher()
    }

    func stopListeningLocations() {
        repository.stopListeningLocations()
    }
}
