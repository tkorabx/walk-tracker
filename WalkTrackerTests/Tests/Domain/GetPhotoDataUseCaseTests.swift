import XCTest
import Combine

@testable import App

class GetPhotoDataUseCaseTests: XCTestCase {

    var SUT: GetPhotoDataUseCaseProtocol!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        super.tearDown()
        SUT = nil
    }

    func testSuccessfulPhotoDataFetch() {
        // Doesn't need to inject ApiClientStub since
        // inject() method already does it for Offline environment
        SUT = GetPhotoDataUseCase()

        SUT
            .tryGettingPhotoData(for: "")
            .expectSuccess(byStoringIn: &cancellables) { data in
                let image = UIImage(data: data)
                XCTAssertNotNil(image)
            }
            .wait(for: self)
    }

    func testPhotoSizeRequestFailure() {
        let failingStub = GetPhotoSizesRepository(apiClient: .inject(failureStub: URLError(.callIsActive)))
        SUT = GetPhotoDataUseCase(sizesRepository: failingStub)

        SUT
            .tryGettingPhotoData(for: "")
            .expectFailure(byStoringIn: &cancellables) { error in
                XCTAssertTrue(error is URLError)
            }
            .wait(for: self)
    }

    func testPhotoDataRequestFailure() {
        let failingStub = GetPhotoDataRepository(apiClient: .inject(failureStub: URLError(.callIsActive)))
        SUT = GetPhotoDataUseCase(dataRepository: failingStub)

        SUT
            .tryGettingPhotoData(for: "")
            .expectFailure(byStoringIn: &cancellables) { error in
                XCTAssertTrue(error is URLError)
            }
            .wait(for: self)
    }
}
