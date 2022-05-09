import Foundation
import Combine

protocol ApiClientProtocol {
    func execute<Success: Decodable>(request: URLRequest) -> AnyPublisher<Success, Error>
    func dataTaskPublisher(from request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error>
}

extension ApiClientProtocol {

    func execute<Success: Decodable>(request: URLRequest) -> AnyPublisher<Success, Error> {
        dataTaskPublisher(from: request)
            .catch { error -> Fail<URLSession.DataTaskPublisher.Output, Error> in
                log("⛔️ Request Failed", error.localizedDescription)
                return Fail(error: error)
            }
            .tryMap { (data: Data, response: URLResponse) in

                log("✅ Request Succeeded")

                if Success.self is RawResource.Type, let resource = RawResource(data: data) as? Success {
                    return resource
                } else {
                    log(String(data: data, encoding: .utf8) ?? "")
                    return try JSONDecoder.apiDecoder.decode(Success.self, from: data)
                }
            }
            .eraseToAnyPublisher()
    }
}

private extension JSONDecoder {
    static let apiDecoder = JSONDecoder()
}

// Methods automatically checking and settings connection types depending on the configuration:
// - ApiClient - connected to remote services and used to download real images
// - ApiClientStub - isolated client which stubs connection with local resources (used for App Offline and Unit Tests)
extension ApiClientProtocol where Self == ApiClient {

    static func inject(successStub: String) -> ApiClientProtocol {
        Environment.isAppOffline ? ApiClientStub(file: successStub) : ApiClient()
    }

    static func inject(rawStub: String) -> ApiClientProtocol {
        Environment.isAppOffline ? ApiClientStub(raw: rawStub) : ApiClient()
    }

    static func inject(failureStub: Error) -> ApiClientProtocol {
        Environment.isAppOffline ? ApiClientStub(error: failureStub) : ApiClient()
    }
}
