import Foundation
import Combine
import UIKit

protocol GetPhotoDataUseCaseProtocol {
    func tryGettingPhotoData(for id: String) -> AnyPublisher<Data, Error>
}

protocol GetPhotoSizesRepositoryProtocol {
    func getPhotoSizes(for id: String) -> AnyPublisher<PhotoSizes, Error>
}

protocol GetPhotoDataRepositoryProtocol {
    func getPhotoData(url: URL) -> AnyPublisher<RawResource, Error>
}

final class GetPhotoDataUseCase: GetPhotoDataUseCaseProtocol {

    private let sizesRepository: GetPhotoSizesRepositoryProtocol
    private let dataRepository: GetPhotoDataRepositoryProtocol

    init(
        sizesRepository: GetPhotoSizesRepositoryProtocol = GetPhotoSizesRepository(),
        dataRepository: GetPhotoDataRepositoryProtocol = GetPhotoDataRepository()
    ) {
        self.sizesRepository = sizesRepository
        self.dataRepository = dataRepository
    }

    func tryGettingPhotoData(for id: String) -> AnyPublisher<Data, Error> {
        sizesRepository
            .getPhotoSizes(for: id)
            .flatMap { [weak self] sizes -> AnyPublisher<Data, Error> in
                guard let self = self, let size = self.chooseProperSize(of: sizes) else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }

                return self.dataRepository
                    .getPhotoData(url: size.source)
                    .flatMap { element in
                        Just(element.data).setFailureType(to: Error.self)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func chooseProperSize(of sizes: PhotoSizes) -> PhotoSizes.Sizes.Size? {
        sizes
            .sizes
            .size
            .first(where: { $0.width > UIScreen.main.bounds.width }) ?? sizes.sizes.size.last
    }
}
