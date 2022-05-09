import Foundation
import Combine
import XCTest

extension AnyPublisher {
    
    func expectSuccess(byStoringIn cancellables: inout Set<AnyCancellable>, _ conditions: @escaping (Output) -> Void) -> XCTestExpectation {
        let expectation = XCTestExpectation()
        
        sink(receiveCompletion: { _ in }) { output in
            conditions(output)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        return expectation
    }
    
    func expectFailure(byStoringIn cancellables: inout Set<AnyCancellable>, _ conditions: @escaping (Failure) -> Void) -> XCTestExpectation {
        let expectation = XCTestExpectation()
        
        sink(receiveCompletion: { result in
            switch result {
            case .failure(let error):
                conditions(error)
                expectation.fulfill()
            case .finished:
                XCTFail()
            }
        }) { _ in }
        .store(in: &cancellables)
        
        return expectation
    }
}

extension XCTestExpectation {
    
    func wait(for test: XCTestCase) {
        // Timeout is not adjustable to keep unit tests fast
        test.wait(for: [self], timeout: 0.5)
    }
}
