import Foundation
import Combine

@testable import App

struct RequestAnalyzer: ApiClientProtocol {

    let conditions: (URLRequest) -> Void

    init(_ conditions: @escaping (URLRequest) -> Void) {
        self.conditions = conditions
    }

    func dataTaskPublisher(from request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
        conditions(request)
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
}
