import Foundation
import Combine
import CoreLocation
import UIKit

protocol CLLocationManagerProtocol: AnyObject {
    var allowsBackgroundLocationUpdates: Bool { get set }
    var delegate: CLLocationManagerDelegate? { get set }
    var authorizationStatus: CLAuthorizationStatus { get }
    var locationServicesEnabled: Bool { get }

    func requestAlwaysAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

extension CLLocationManager: CLLocationManagerProtocol {

    var locationServicesEnabled: Bool {
        CLLocationManager.locationServicesEnabled()
    }
}

final class GeoDataRepository: NSObject, GeoDataRepositoryProtocol {

    private var subject = PassthroughSubject<CLLocation, Error>()
    private let locationManager: CLLocationManagerProtocol

    init(locationManager: CLLocationManagerProtocol = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.allowsBackgroundLocationUpdates = true
    }

    func requestLocationsIfPossible() -> AnyPublisher<CLLocation, Error> {
        subject = .init()
        checkPermissions()
        return subject.eraseToAnyPublisher()
    }

    private func checkPermissions() {
        guard locationManager.locationServicesEnabled else {
            subject.send(completion: .failure(GeoDataError.permissionsDisabled))
            return
        }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        default:
            subject.send(completion: .failure(GeoDataError.permissionsDisabled))
        }
    }

    func stopListeningLocations() {
        locationManager.stopUpdatingLocation()
    }
}

extension GeoDataRepository: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkPermissions()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let last = locations.last {
            log("📍 Latitude: \(last.coordinate.latitude), Longitude: \(last.coordinate.longitude)")
            subject.send(last)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        subject.send(completion: .failure(error))
    }
}
