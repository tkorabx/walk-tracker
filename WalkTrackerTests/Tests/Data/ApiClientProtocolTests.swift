import XCTest
import Combine

@testable import App

class ApiClientProtocolTests: XCTestCase {

    var SUT: ApiClientProtocol!
    var cancellables: Set<AnyCancellable>!
    var request: URLRequest!

    override func setUp() {
        super.setUp()
        cancellables = []

        if let url = URL(string: UIApplication.openSettingsURLString) {
            request = URLRequest(url: url)
        } else {
            fatalError()
        }
    }

    override func tearDown() {
        super.tearDown()
        SUT = nil
    }

    func testSuccessfulSharedExecuteMethodWithJsonOutput() {
        SUT = ApiClientStub(file: "GeoPhotoSizes")

        SUT
            .execute(request: request)
            .expectSuccess(byStoringIn: &cancellables) { (output: PhotoSizes) in
                XCTAssertEqual(output.sizes.size.count, 14)
                XCTAssertEqual(output.sizes.size.first?.label, "Square")
            }
            .wait(for: self)
    }

    func testSuccessfulSharedExecuteMethodWithRawOutput() {
        // Stubbed with "globe" SF Symbol image
        SUT = ApiClientStub(raw: "globe")

        SUT
            .execute(request: request)
            .expectSuccess(byStoringIn: &cancellables) { (output: RawResource) in
                XCTAssertNotNil(UIImage(data: output.data))
            }
            .wait(for: self)
    }

    func testFailingSharedExecuteMethod() {
        SUT = ApiClientStub(error: URLError(.callIsActive))

        SUT
            .execute(request: request)
            // Just to specify return type
            .map { (value: String) in }
            .eraseToAnyPublisher()
            .expectFailure(byStoringIn: &cancellables) { error in
                XCTAssertTrue(error is URLError)
            }
            .wait(for: self)
    }
}
