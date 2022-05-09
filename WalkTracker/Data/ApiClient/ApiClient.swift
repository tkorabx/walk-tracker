import Foundation
import Combine

final class ApiClient: ApiClientProtocol {

    let session: URLSession = .shared

    func dataTaskPublisher(from request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
        log("🚀 Sending Request", request.url?.absoluteString ?? "")
        return session.dataTaskPublisher(for: request)
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
}
