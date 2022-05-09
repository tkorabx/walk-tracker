import UIKit
import Combine

final class ApiClientStub: ApiClientProtocol {

    let data: Data?
    let error: Error?

    /// Used for stubbing JSON responses with local resources
    init(file resourceName: String) {
        guard let url = Bundle(for: Self.self).url(forResource: resourceName, withExtension: "json") else {
            fatalError("Couldn't load resource: \(resourceName)")
        }

        do {
            self.data = try Data(contentsOf: url)
            self.error = nil
        } catch {
            fatalError("Couldn't load contents for: \(url.absoluteString)")
        }
    }

    // Used for stubbing binary data with SF Symbol images
    init(raw resourceName: String) {
        guard let data = UIImage(systemName: resourceName)?.pngData() else {
            fatalError("Couldn't create stub resource for \(resourceName)")
        }

        self.data = data
        self.error = nil
    }

    init(error: Error) {
        self.error = error
        self.data = nil
    }

    func dataTaskPublisher(from request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
        guard Environment.isAppOffline else {
            fatalError("Invalid configuration")
        }

        if let data = data {
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return Just((data: data, response: response))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else if let error = error {
            return Result.Publisher(error)
                .eraseToAnyPublisher()
        } else {
            fatalError("Invalid coniguration or using it in non-testing mode")
        }
    }
}
