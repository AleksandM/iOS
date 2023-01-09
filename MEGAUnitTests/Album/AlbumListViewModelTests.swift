import XCTest
import Combine
import MEGADomainMock
import MEGADomain
@testable import MEGA

final class AlbumListViewModelTests: XCTestCase {
    private var subscriptions = Set<AnyCancellable>()
    
    func testLoadAlbums_onAlbumsLoaded_albumsAreLoadedAndTitlesAreUpdated() async throws {
        let favouriteAlbum = AlbumEntity(id: 1, name: "", coverNode: NodeEntity(handle: 1), count: 1, type: .favourite)
        let gifAlbum = AlbumEntity(id: 2, name: "", coverNode: NodeEntity(handle: 1), count: 1, type: .gif)
        let rawAlbum = AlbumEntity(id: 3, name: "", coverNode: NodeEntity(handle: 2), count: 1, type: .raw)
        let userAlbum = AlbumEntity(id: 3, name: "Custom Name", coverNode: NodeEntity(handle: 3), count: 1, type: .user)
        let useCase = MockAlbumListUseCase(albums: [favouriteAlbum, gifAlbum, rawAlbum, userAlbum])
        let sut = AlbumListViewModel(usecase: useCase, alertViewModel: alertViewModel())
        
        let exp = expectation(description: "albums titles are updated when retrieved")
        sut.$albums
            .dropFirst()
            .sink {
                XCTAssertEqual($0, [
                    favouriteAlbum.update(name: Strings.Localizable.CameraUploads.Albums.Favourites.title),
                    gifAlbum.update(name: Strings.Localizable.CameraUploads.Albums.Gif.title),
                    rawAlbum.update(name: Strings.Localizable.CameraUploads.Albums.Raw.title),
                    userAlbum
                ])
                exp.fulfill()
            }.store(in: &subscriptions)
        await sut.loadAlbums()
        await sut.albumLoadingTask?.value
        wait(for: [exp], timeout: 2.0)
    }
    
    func testLoadAlbums_onAlbumsLoadedFinsihed_shouldLoadSetToFalse() async throws {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), alertViewModel: alertViewModel())
        let exp = expectation(description: "should load set after album load")
        
        sut.$shouldLoad
            .dropFirst()
            .sink {
                XCTAssertFalse($0)
                exp.fulfill()
            }.store(in: &subscriptions)
        
        await sut.loadAlbums()
        await sut.albumLoadingTask?.value
        wait(for: [exp], timeout: 2.0)
    }
    
    func testCancelLoading_stopMonitoringForNodeUpdates() async throws {
        let useCase = MockAlbumListUseCase()
        let sut = AlbumListViewModel(usecase: useCase, alertViewModel: alertViewModel())
        XCTAssertTrue(useCase.startMonitoringNodesUpdateCalled == 0)
        XCTAssertTrue(useCase.stopMonitoringNodesUpdateCalled == 0)
        await sut.loadAlbums()
        XCTAssertTrue(useCase.startMonitoringNodesUpdateCalled == 1)
        sut.cancelLoading()
        XCTAssertTrue(useCase.stopMonitoringNodesUpdateCalled == 1)
    }
    
    @MainActor
    func testCreateUserAlbum_shouldCreateUserAlbum() {
        let exp = expectation(description: "should load album at first after creating")
        let useCase = MockAlbumListUseCase()
        let sut = AlbumListViewModel(usecase: useCase, alertViewModel: alertViewModel())
        sut.createUserAlbum(with: "userAlbum")
        sut.$shouldLoad
            .dropFirst()
            .sink {
                XCTAssertFalse($0)
                exp.fulfill()
            }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2.0)
        XCTAssertEqual(sut.albums.last?.name, "userAlbum")
        XCTAssertEqual(sut.albums.last?.type, .user)
        XCTAssertEqual(sut.albums.last?.count, 0)
    }
    
    func testNewAlbumName_whenAlbumContainsNoNewAlbum() async {
        let useCase = MockAlbumListUseCase()
        let sut = AlbumListViewModel(usecase: useCase, alertViewModel: alertViewModel())
        await sut.loadAlbums()
        await sut.albumLoadingTask?.value
        XCTAssertEqual(sut.newAlbumName(), Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder)
    }
    
    func testNewAlbumName_whenAlbumContainsNewAlbum() async {
        let newAlbum = MockAlbumListUseCase.sampleUserAlbum(name: Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder)
        let useCase = MockAlbumListUseCase(albums: [newAlbum])
        let sut = AlbumListViewModel(usecase: useCase, alertViewModel: alertViewModel())
        await sut.loadAlbums()
        await sut.albumLoadingTask?.value
        XCTAssertEqual(sut.albums.count, 1)
        XCTAssertEqual(sut.newAlbumName(), Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder + " \("(1)")")
    }
    
    func testValidateAlbum_whenAlbumNameIsNil_returnsNil() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), alertViewModel: alertViewModel())
        XCTAssertNil(sut.validateAlbum(name: nil))
    }
    
    func testValidateAlbum_whenAlbumNameIsEmpty_returnsNil() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), alertViewModel: alertViewModel())
        XCTAssertNil(sut.validateAlbum(name: ""))
    }
    
    func testValidateAlbum_whenAlbumNameContainsInvalidChars_returnsErrorMessage() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), alertViewModel: alertViewModel())
        XCTAssertNotNil(sut.validateAlbum(name: "userAlbum:/;"))
    }
    
    func testValidateAlbum_whenAlbumNameIsSameAsExistingUserAlbum_returnsErrorMessage() async {
        let newAlbum = MockAlbumListUseCase.sampleUserAlbum(name: "userAlbum")
        let useCase = MockAlbumListUseCase(albums: [newAlbum])
        let sut = AlbumListViewModel(usecase: useCase, alertViewModel: alertViewModel())
        await sut.loadAlbums()
        await sut.albumLoadingTask?.value
        XCTAssertEqual(sut.albums.count, 1)
        XCTAssertNotNil(sut.validateAlbum(name: newAlbum.name))
    }
    
    func testValidateAlbum_whenAlbumNameIsSameAsExistingSystemAlbum_returnsErrorMessage() async {
        let newSysAlbum = AlbumEntity(id: AlbumIdEntity.favourite.rawValue, name: Strings.Localizable.CameraUploads.Albums.Favourites.title, coverNode: NodeEntity(handle: AlbumIdEntity.favourite.rawValue), count: 0, type: .favourite)
        let useCase = MockAlbumListUseCase(albums: [newSysAlbum])
        let sut = AlbumListViewModel(usecase: useCase, alertViewModel: alertViewModel())
        await sut.loadAlbums()
        await sut.albumLoadingTask?.value
        XCTAssertEqual(sut.albums.count, 1)
        XCTAssertNotNil(sut.validateAlbum(name: newSysAlbum.name))
    }
    
    private func alertViewModel() -> TextFieldAlertViewModel {
        TextFieldAlertViewModel(title: Strings.Localizable.CameraUploads.Albums.Create.Alert.title,
                                                   placeholderText: Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder,
                                                   affirmativeButtonTitle: Strings.Localizable.createFolderButton,
                                                   message: nil)
    }
}

