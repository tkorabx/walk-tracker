import Foundation
import Combine

final class GetPhotoSizesRepository: GetPhotoSizesRepositoryProtocol {

    private let apiClient: ApiClientProtocol

    init(apiClient: ApiClientProtocol = .inject(successStub: "GeoPhotoSizes")) {
        self.apiClient = apiClient
    }

    func getPhotoSizes(for id: String) -> AnyPublisher<PhotoSizes, Error> {
        let request = RequestBuilder(
            path: "/services/rest",
            queries: [
                "api_key": Environment.flickrApiKey,
                "format": "json",
                "nojsoncallback": "1",
                "method": "flickr.photos.getSizes",
                "photo_id": id
            ]
        ).build()

        return apiClient.execute(request: request)
    }
}
