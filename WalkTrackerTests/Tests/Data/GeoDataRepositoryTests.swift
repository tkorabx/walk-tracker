import XCTest
import Combine
import CoreLocation

@testable import App

class GeoDataRepositoryTests: XCTestCase {

    var SUT: GeoDataRepositoryProtocol!
    var locationManager: CLLocationManagerMock!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
        locationManager = .init()
        SUT = GeoDataRepository(locationManager: locationManager)
    }

    override func tearDown() {
        super.tearDown()
        locationManager = nil
        SUT = nil
    }

    func testInitialSetup() {
        XCTAssertTrue(locationManager.allowsBackgroundLocationUpdates)
    }

    func testNotDeterminedAuthorization() {
        _ = SUT.requestLocationsIfPossible()
        XCTAssertTrue(locationManager.didCallRequestAlwaysAuthorization)
    }

    func testGrantedAuthorization() {
        locationManager.authorizationStatusStub = .authorizedAlways
        _ = SUT.requestLocationsIfPossible()
        XCTAssertTrue(locationManager.didCallStartUpdating)
    }

    func testDeniedAuthorization() {
        locationManager.authorizationStatusStub = .denied

        SUT
            .requestLocationsIfPossible()
            .expectFailure(byStoringIn: &cancellables) { error in
                XCTAssertTrue(error is GeoDataError)
            }
            .wait(for: self)
    }

    func testLocationServicesDisabled() {
        locationManager.locationServicesEnabledStub = false

        SUT
            .requestLocationsIfPossible()
            .expectFailure(byStoringIn: &cancellables) { error in
                XCTAssertTrue(error is GeoDataError)
            }
            .wait(for: self)
    }

    func testStopping() {
        SUT.stopListeningLocations()
        XCTAssertTrue(locationManager.didCallStopUpdating)
    }
}

extension GeoDataRepositoryTests {

    class CLLocationManagerMock: CLLocationManagerProtocol {

        var allowsBackgroundLocationUpdates: Bool = false
        var delegate: CLLocationManagerDelegate?
        var authorizationStatusStub: CLAuthorizationStatus = .notDetermined
        var locationServicesEnabledStub: Bool = true

        var didCallRequestAlwaysAuthorization = false
        var didCallStartUpdating = false
        var didCallStopUpdating = false

        var authorizationStatus: CLAuthorizationStatus {
            authorizationStatusStub
        }

        var locationServicesEnabled: Bool {
            locationServicesEnabledStub
        }

        func requestAlwaysAuthorization() {
            didCallRequestAlwaysAuthorization = true
        }

        func startUpdatingLocation() {
            didCallStartUpdating = true
        }

        func stopUpdatingLocation() {
            didCallStopUpdating = true
        }
    }
}
