import Foundation
import Combine
import UIKit

final class ListViewModel: ObservableObject {

    struct ViewState {

        var isAlertPresented: Bool = false

        fileprivate(set) var content: Content {
            didSet {
                isAlertPresented = false
            }
        }

        enum Content: Equatable {
            case content([RowViewModel])
            case empty
            case noPermissions
            case idle
        }
    }

    @Published var viewState: ViewState = .init(content: .idle)

    private let geoDataUseCase: GeoDataUseCaseProtocol
    private let geoSearchPhotoUseCase: GeoSearchPhotoUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        geoDataUseCase: GeoDataUseCaseProtocol = GeoDataUseCase(),
        geoSearchPhotoUseCase: GeoSearchPhotoUseCaseProtocol = GeoSearchPhotoUseCase()
    ) {
        self.geoDataUseCase = geoDataUseCase
        self.geoSearchPhotoUseCase = geoSearchPhotoUseCase
    }

    func startButtonHasBeenSelected() {
        viewState.content = .empty

        geoDataUseCase
            .tryListeningLocations()
            .flatMap { [unowned self] location -> AnyPublisher<GeoSearchedPhotos.Photos.Photo, Error> in
                self.geoSearchPhotoUseCase
                    .tryGeoSearchingPhoto(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
            }
            .map(toViewState)
            .sink(receiveCompletion: handleCompletion) { [unowned self] output in
                self.viewState = output
            }
            .store(in: &cancellables)
    }

    func stopButtonHasBeenSelected() {
        stop(isAlertIndicatingError: false)
    }

    func openSettingsButtonHasBeenSelected() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
            viewState.content = .idle
        }
    }

    private func toViewState(_ input: GeoSearchedPhotos.Photos.Photo) -> ViewState {
        let newViewModel = RowViewModel(photoId: input.id)

        switch viewState.content {
        case .content(var viewModels):
            if viewModels.contains(where: { $0.id == input.id }) {
                log("🔁 Blocked duplication of images")
                return viewState
            } else {
                viewModels.insert(newViewModel, at: 0)
                viewState.content = .content(viewModels)
                return viewState
            }
        case .empty:
            viewState.content = .content([newViewModel])
            return viewState
        default:
            fatalError("Impossible to happen")
        }
    }

    private func handleCompletion(_ completion: Subscribers.Completion<Error>) {
        guard case .failure(let error) = completion else {
            return
        }

        switch error {
        case is GeoDataError:
            viewState.content = .noPermissions
        default:
            stop(isAlertIndicatingError: true)
        }
    }

    private func stop(isAlertIndicatingError: Bool) {
        geoDataUseCase.stopListeningLocations()
        cancellables = []
        viewState.content = .idle
        viewState.isAlertPresented = isAlertIndicatingError
    }
}
