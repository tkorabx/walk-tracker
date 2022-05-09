import XCTest
import Combine

@testable import App

class GeoSearchPhotosRepositoryTests: XCTestCase {

    var SUT: GeoSearchPhotosRepositoryProtocol!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        super.tearDown()
        SUT = nil
    }

    func testRequest() {
        let analyzer = RequestAnalyzer { request in
            guard let url = request.url else {
                XCTFail()
                return
            }

            XCTAssertEqual(url.scheme, "mock")
            XCTAssertEqual(url.host, "www.flickr.com")
            XCTAssertEqual(url.path, "/services/rest")
            XCTAssertTrue(url.query?.contains("api_key=12345") ?? false)
            XCTAssertTrue(url.query?.contains("lat=0.0") ?? false)
            XCTAssertTrue(url.query?.contains("lon=0.0") ?? false)
            XCTAssertTrue(url.query?.contains("radius=0.5") ?? false)
        }

        SUT = GeoSearchPhotosRepository(apiClient: analyzer)
        _ = SUT.geoSearchPhotos(latitide: 0.0, longitude: 0.0, radius: 0.5)
    }

    func testGeoSearchPhotos() {
        // Doesn't need to inject ApiClientStub since
        // inject() method already does it for Offline environment
        SUT = GeoSearchPhotosRepository()

        SUT
            .geoSearchPhotos(latitide: 0.0, longitude: 0.0, radius: 0.5)
            .expectSuccess(byStoringIn: &cancellables) { photos in
                XCTAssertEqual(photos.photos.photo.count, 1)
                XCTAssertEqual(photos.photos.photo.first?.id, "51099243889")
            }
            .wait(for: self)
    }

    func testFailure() {
        SUT = GeoSearchPhotosRepository(apiClient: .inject(failureStub: URLError(.callIsActive)))

        SUT
            .geoSearchPhotos(latitide: 0.0, longitude: 0.0, radius: 0.1)
            .expectFailure(byStoringIn: &cancellables) { error in
                XCTAssertTrue(error is URLError)
            }
            .wait(for: self)
    }
}
