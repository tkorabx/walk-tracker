import UIKit
import Combine

final class RowViewModel: ObservableObject, Identifiable {

    enum ViewState {
        case image(UIImage)
        case placeholder
    }

    @Published var viewState: ViewState = .placeholder

    let id: String

    private let useCase: GetPhotoDataUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(photoId: String, useCase: GetPhotoDataUseCaseProtocol = GetPhotoDataUseCase()) {
        self.id = photoId
        self.useCase = useCase
    }

    func onAppear() {
        useCase
            .tryGettingPhotoData(for: id)
            .compactMap(UIImage.init)
            .map(ViewState.image)
            .replaceError(with: .placeholder)
            .receive(on: DispatchQueue.main)
            .assign(to: \.viewState, on: self)
            .store(in: &cancellables)
    }
}

extension RowViewModel: Equatable {

    static func == (lhs: RowViewModel, rhs: RowViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
