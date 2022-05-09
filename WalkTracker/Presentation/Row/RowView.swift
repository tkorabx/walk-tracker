import SwiftUI

struct RowView: View {

    @StateObject var viewModel: RowViewModel

    init(viewModel: RowViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
            GeometryReader { proxy in
                switch viewModel.viewState {
                case .image(let uiImage):
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                        .background(Color.yellow)
                        .clipped()
                case .placeholder:
                    HStack {
                        Spacer()
                        Image(systemName: "photo.artframe")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(30)
                        Spacer()
                    }
                }
            }
        }
        .aspectRatio(1.8, contentMode: .fit)
        .onAppear(perform: viewModel.onAppear)
    }
}
