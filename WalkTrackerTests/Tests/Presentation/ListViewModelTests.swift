import XCTest
import Combine
import CoreLocation

@testable import App

class ListViewModelTests: XCTestCase {

    var SUT: ListViewModel!
    var useCase: GeoDataUseCaseMock!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
        useCase = GeoDataUseCaseMock()
        // Mocking only geoDataUseCase since geoSearchPhotoUseCase will be mocked by environment
        SUT = ListViewModel(geoDataUseCase: useCase)
    }

    override func tearDown() {
        super.tearDown()
        SUT = nil
    }

    func testStartButtonSelectionGoingSuccessful() {
        var expectedViewStates: [ListViewModel.ViewState.Content] = [
            .idle,
            .empty,
            .content([RowViewModel(photoId: "51099243889")])
        ]

        SUT.$viewState
            .eraseToAnyPublisher()
            .expectSuccess(byStoringIn: &cancellables) { viewState in
                XCTAssertTrue(viewState.content == expectedViewStates.first)
                if !expectedViewStates.isEmpty {
                    expectedViewStates.removeFirst()
                }
            }
            .wait(for: self)

        SUT.startButtonHasBeenSelected()
    }

    func testStartButtonSelectionWithFailedPermissions() {
        useCase = GeoDataUseCaseMock(error: GeoDataError.permissionsDisabled)
        SUT = ListViewModel(geoDataUseCase: useCase)

        var expectedViewStates: [ListViewModel.ViewState.Content] = [
            .idle,
            .empty,
            .noPermissions
        ]

        SUT.$viewState
            .eraseToAnyPublisher()
            .expectSuccess(byStoringIn: &cancellables) { viewState in
                XCTAssertTrue(viewState.content == expectedViewStates.first)
                if !expectedViewStates.isEmpty {
                    expectedViewStates.removeFirst()
                }
            }
            .wait(for: self)

        SUT.startButtonHasBeenSelected()
    }

    func testStopButtonSelection() {
        SUT.stopButtonHasBeenSelected()

        XCTAssertTrue(useCase.didCallStop)
        XCTAssertEqual(SUT.viewState.content, .idle)
        XCTAssertEqual(SUT.viewState.isAlertPresented, false)
    }
}

extension ListViewModelTests {

    class GeoDataUseCaseMock: GeoDataUseCaseProtocol {

        let error: Error?
        var didCallStop = false

        init(error: Error? = nil) {
            self.error = error
        }

        func tryListeningLocations() -> AnyPublisher<CLLocation, Error> {
            if let error = error {
                return Fail(error: error)
                    .eraseToAnyPublisher()
            } else {
                let location = CLLocation(latitude: 0.0, longitude: 0.0)
                return Just(location)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }

        func stopListeningLocations() {
            didCallStop = true
        }
    }
}
