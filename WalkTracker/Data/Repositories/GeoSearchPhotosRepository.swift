import Foundation
import Combine

final class GeoSearchPhotosRepository: GeoSearchPhotosRepositoryProtocol {

    private let apiClient: ApiClientProtocol

    init(apiClient: ApiClientProtocol = .inject(successStub: "GeoSearchPhotos")) {
        self.apiClient = apiClient
    }

    func geoSearchPhotos(latitide: Double, longitude: Double, radius: Double) -> AnyPublisher<GeoSearchedPhotos, Error> {
        let request = RequestBuilder(
            path: "/services/rest",
            queries: [
                "api_key": Environment.flickrApiKey,
                "format": "json",
                "nojsoncallback": "1",
                "method": "flickr.photos.search",
                "content_type": "1",
                "lat": "\(latitide)",
                "lon": "\(longitude)",
                "radius": "\(radius)",
                "per_page": "1"
            ]
        ).build()

        return apiClient.execute(request: request)
    }
}
