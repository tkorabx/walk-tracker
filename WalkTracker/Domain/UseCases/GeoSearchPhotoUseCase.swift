import Combine
import UIKit

enum GeoSearchPhotoError: Error {
    case noPhotosForCurrentLocation
}

protocol GeoSearchPhotoUseCaseProtocol {
    func tryGeoSearchingPhoto(latitude: Double, longitude: Double) -> AnyPublisher<GeoSearchedPhotos.Photos.Photo, Error>
}

protocol GeoSearchPhotosRepositoryProtocol {
    func geoSearchPhotos(latitide: Double, longitude: Double, radius: Double) -> AnyPublisher<GeoSearchedPhotos, Error>
}

final class GeoSearchPhotoUseCase: GeoSearchPhotoUseCaseProtocol {

    private let repository: GeoSearchPhotosRepositoryProtocol

    init(repository: GeoSearchPhotosRepositoryProtocol = GeoSearchPhotosRepository()) {
        self.repository = repository
    }

    func tryGeoSearchingPhoto(latitude: Double, longitude: Double) -> AnyPublisher<GeoSearchedPhotos.Photos.Photo, Error> {
        repository
            .geoSearchPhotos(latitide: latitude, longitude: longitude, radius: Radius.small.rawValue)
            .flatMap { [weak self] firstGeoSearchedPhotos -> AnyPublisher<GeoSearchedPhotos.Photos.Photo, Error> in
                guard let self = self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }

                if let photo = firstGeoSearchedPhotos.photos.photo.first {
                    return Just(photo)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return self.repository
                        .geoSearchPhotos(latitide: latitude, longitude: longitude, radius: Radius.big.rawValue)
                        .tryMap { secondGeoSearchedPhotos -> GeoSearchedPhotos.Photos.Photo in
                            if let photo = secondGeoSearchedPhotos.photos.photo.first {
                                return photo
                            } else {
                                throw GeoSearchPhotoError.noPhotosForCurrentLocation
                            }
                        }
                        .flatMap {
                            Just($0).setFailureType(to: Error.self)
                        }
                        .eraseToAnyPublisher()
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

private extension GeoSearchPhotoUseCase {

    enum Radius: Double {
        case small = 0.1
        case big = 1.0
    }
}
