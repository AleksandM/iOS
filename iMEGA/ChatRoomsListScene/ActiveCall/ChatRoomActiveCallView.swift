import MEGADesignToken
import SwiftUI

struct ChatRoomActiveCallView: View {
    @Environment(\.colorScheme) private var colorScheme

    @ObservedObject var viewModel: ActiveCallViewModel
    
    var body: some View {
        HStack {
            Spacer()
            Text(viewModel.message)
                .font(.caption)
                .bold()
                .foregroundColor(
                    isDesignTokenEnabled ?
                        TokenColors.Text.inverseAccent.swiftUI :
                        UIColor.whiteFFFFFF.swiftUI
                )
            Image(uiImage: viewModel.muted)
            Image(uiImage: viewModel.video)
            Spacer()
        }
        .padding(8)
        .frame(maxHeight: 44)
        .background(backgroundColor(isReconnecting: viewModel.isReconnecting))
        .onTapGesture {
            viewModel.activeCallViewTapped()
        }
    }
    
    func backgroundColor(isReconnecting: Bool) -> Color {
        if isReconnecting {
            return Color(.systemOrange)
        } else {
            if isDesignTokenEnabled {
                return TokenColors.Button.primary.swiftUI
            } else {
                return colorScheme == .dark ? UIColor.green00C29A.swiftUI : UIColor.green00A886.swiftUI
            }
        }
    }
}
