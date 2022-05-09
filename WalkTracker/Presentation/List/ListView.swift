import SwiftUI

struct ListView: View {

    private typealias ButtonAction = (title: String, action: () -> Void)

    @StateObject private var viewModel = ListViewModel()

    var body: some View {
        ZStack {
            switch viewModel.viewState.content {
            case .content(let viewModels):
                List {
                    ForEach(viewModels) { viewModel in
                        RowView(viewModel: viewModel)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("navigation.stop.button.title", action: viewModel.stopButtonHasBeenSelected)
                    }
                }
            case .idle:
                informationView(
                    title: "idle.title",
                    description: "idle.description",
                    buttonAction: ("idle.button.title", viewModel.startButtonHasBeenSelected)
                )
            case .noPermissions:
                informationView(
                    title: "no.permissions.title",
                    description: "no.permissions.description",
                    buttonAction: ("no.permissions.button.title", viewModel.openSettingsButtonHasBeenSelected)
                )
            case .empty:
                informationView(
                    title: "empty.title",
                    description: "empty.description"
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "alert.title".localized,
            isPresented: $viewModel.viewState.isAlertPresented,
            actions: {
                Button("alert.ok", action: {})
            },
            message: { Text("alert.description".localized) }
        )
    }

    private func informationView(title: String, description: String, buttonAction: ButtonAction? = nil) -> some View {
        VStack(spacing: 16) {
            Text(title.localized)
                .font(.title)
            Text(description.localized)
                .multilineTextAlignment(.center)
            if let buttonAction = buttonAction {
                ZStack {
                    Color
                        .accentColor
                        .cornerRadius(10)
                    Button(action: buttonAction.action) {
                        Text(buttonAction.title.localized)
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .medium))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                    }
                }
                .fixedSize()
            }
        }
        .padding()
    }
}

private extension String {

    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
