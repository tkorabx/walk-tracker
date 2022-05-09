import Foundation
import Combine

final class GetPhotoDataRepository: GetPhotoDataRepositoryProtocol {

    private let apiClient: ApiClientProtocol
    private let cache: PhotoDataCache

    init(
        // Stubbed with "globe" SF Symbol image
        apiClient: ApiClientProtocol = .inject(rawStub: "globe"),
        cache: PhotoDataCache = .photoDataCache
    ) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func getPhotoData(url: URL) -> AnyPublisher<RawResource, Error> {
        if let cachedData = cache.object(forKey: url.absoluteString as NSString) as Data? {
            log("⭐️ Using image from cache")
            return Just(RawResource(data: cachedData))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let request = URLRequest(url: url)
        return apiClient
            .execute(request: request)
            .handleEvents(receiveOutput: { [weak cache] value in
                cache?.setObject(value.data as NSData, forKey: url.absoluteString as NSString)
            })
            .eraseToAnyPublisher()
    }
}
