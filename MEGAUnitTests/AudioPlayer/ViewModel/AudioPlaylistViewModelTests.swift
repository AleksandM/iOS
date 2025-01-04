@testable import MEGA
import XCTest

final class AudioPlaylistViewModelTests: XCTestCase {
    let router = MockAudioPlaylistViewRouter()
    let playerHandler = MockAudioPlayerHandler()
    
    @MainActor
    lazy var viewModel = AudioPlaylistViewModel(configEntity: AudioPlayerConfigEntity(parentNode: MEGANode(), playerHandler: playerHandler),
                                                router: router)
    
    @MainActor func testAudioPlayerActions() throws {
        let mockPlayerCurrentItem = AudioPlayerItem.mockItem
        playerHandler.mockPlayerCurrentItem = mockPlayerCurrentItem
        test(
            viewModel: viewModel,
            action: .onViewDidLoad,
            expectedCommands: [.reloadTracks(currentItem: mockPlayerCurrentItem, queue: nil, selectedIndexPaths: []), .title(title: "")]
        )
        
        XCTAssertEqual(playerHandler.addPlayerListener_calledTimes, 1)
        
        test(viewModel: viewModel, action: .move(mockPlayerCurrentItem, IndexPath(row: 1, section: 0), MovementDirection.up), expectedCommands: [])
        XCTAssertEqual(playerHandler.onMoveItem_calledTimes, 1)
        
        test(viewModel: viewModel, action: .didSelect(mockPlayerCurrentItem), expectedCommands: [.showToolbar])
        
        test(viewModel: viewModel, action: .removeSelectedItems, expectedCommands: [.deselectAll, .hideToolbar])
        XCTAssertEqual(playerHandler.onDeleteItems_calledTimes, 1)
        
        test(viewModel: viewModel, action: .didDeselect(mockPlayerCurrentItem), expectedCommands: [.hideToolbar])
        
        test(viewModel: viewModel, action: .onViewWillDisappear, expectedCommands: [])
        XCTAssertEqual(playerHandler.removePlayerListener_calledTimes, 1)
        
        test(viewModel: viewModel, action: .willDraggBegin, expectedCommands: [])
        let file1URL = try XCTUnwrap(Bundle.main.url(forResource: "incoming_voice_video_call_iOS9", withExtension: "mp3"))
        let track1 = AudioPlayerItem(name: "file 1", url: file1URL, node: nil)
        viewModel.audio(player: AVQueuePlayer(), reload: track1)
        test(viewModel: viewModel, action: .didDraggEnd, expectedCommands: [.reload(items: [track1])])
    }
    
    @MainActor func testRouterActions() {
        test(viewModel: viewModel, action: .dismiss, expectedCommands: [])
        XCTAssertEqual(router.dismiss_calledTimes, 1)
    }
    
    private func compareAudioPlayerItem(_ item: AudioPlayerItem, _ other: AudioPlayerItem) -> Bool {
        guard let handle = item.node?.handle, let otherHandle = other.node?.handle else {
            return item.url == other.url
        }
        return handle == otherHandle
    }
}
