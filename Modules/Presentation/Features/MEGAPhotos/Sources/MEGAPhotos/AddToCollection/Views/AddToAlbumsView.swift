import ContentLibraries
import MEGAAssets
import MEGADesignToken
import MEGAL10n
import MEGASwiftUI
import MEGAUIComponent
import SwiftUI

struct AddToAlbumsView: View {
    @StateObject var viewModel: AddToAlbumsViewModel
    
    var body: some View {
        content
            .overlay(AlbumListPlaceholderView(
                isActive: !viewModel.isAlbumsLoaded))
            .environment(\.editMode, $viewModel.editMode)
            .alert(isPresented: $viewModel.showCreateAlbumAlert, viewModel.alertViewModel())
            .task {
                await viewModel.monitorUserAlbums()
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.albums.isNotEmpty {
            AlbumListContentView(viewModel: viewModel)
        } else {
            empty
        }
    }
    
    private var empty: some View {
        ContentUnavailableView(label: {
            MEGAAssetsImageProvider.image(named: .playlist)
        }, description: {
            Text(Strings.Localizable.Photos.AddToAlbum.Empty.message)
                .font(.body)
                .foregroundStyle(TokenColors.Text.primary.swiftUI)
        }, actions: {
            MEGAButton(Strings.Localizable.CameraUploads.Albums.CreateAlbum.title,
                       action: viewModel.onCreateAlbumTapped)
            .frame(width: 288)
        })
        .frame(maxHeight: .infinity)
    }
}
