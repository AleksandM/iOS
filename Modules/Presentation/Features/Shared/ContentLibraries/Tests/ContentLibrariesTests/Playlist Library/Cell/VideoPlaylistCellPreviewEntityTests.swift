@testable import ContentLibraries
import MEGADomain
import XCTest

final class VideoPlaylistCellPreviewEntityTests: XCTestCase {
    
    func testShowAddPlaylistButton_whenFavoritePlaylistType_doesNotShowAddButton() {
        let sut = makeSUT(type: .favourite)
        
        XCTAssertFalse(sut.shouldShowAddButton)
    }
    
    func testShowAddPlaylistButton_whenUserPlaylistType_doesNotShowAddButton() {
        let sut = makeSUT(type: .user)
        
        XCTAssertTrue(sut.shouldShowAddButton)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(type: VideoPlaylistEntityType) -> VideoPlaylistCellPreviewEntity {
        VideoPlaylistCellPreviewEntity(
            thumbnail: VideoPlaylistThumbnail(type: .empty, imageContainers: []),
            count: "any",
            duration: "any",
            title: "any",
            isExported: false,
            type: type
        )
    }
    
}
