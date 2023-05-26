import XCTest
import Combine
import MEGADomainMock
import MEGADomain
@testable import MEGA

@MainActor
final class AlbumListViewModelTests: XCTestCase {
    private var subscriptions = Set<AnyCancellable>()
    
    func testLoadAlbums_onAlbumsLoaded_systemAlbumsTitlesAreUpdatedAndAlbumsAreSortedCorrectly() async throws {
        let favouriteAlbum = AlbumEntity(id: 1, name: "", coverNode: NodeEntity(handle: 1), count: 1, type: .favourite)
        let gifAlbum = AlbumEntity(id: 2, name: "", coverNode: NodeEntity(handle: 1), count: 1, type: .gif)
        let rawAlbum = AlbumEntity(id: 3, name: "", coverNode: NodeEntity(handle: 2), count: 1, type: .raw)
        let userAlbum1 = AlbumEntity(id: 4, name: "Album 1", coverNode: NodeEntity(handle: 3),
                                     count: 1, type: .user, creationTime: try "2022-12-31T22:01:04Z".date)
        let userAlbum2 = AlbumEntity(id: 5, name: "Album 2", coverNode: NodeEntity(handle: 4),
                                     count: 1, type: .user, creationTime: try "2022-12-31T22:02:04Z".date)
        let userAlbum3 = AlbumEntity(id: 6, name: "Other Album 1", coverNode: NodeEntity(handle: 5),
                                     count: 1, type: .user, creationTime: try "2022-12-31T22:03:04Z".date)
        let userAlbum4 = AlbumEntity(id: 7, name: "Other Album 4", coverNode: NodeEntity(handle: 6),
                                     count: 1, type: .user, creationTime: try "2022-12-31T22:04:04Z".date)
        let userAlbum5 = AlbumEntity(id: 8, name: "Album 5", coverNode: NodeEntity(handle: 7),
                                     count: 1, type: .user, creationTime: try "2022-12-31T22:05:04Z".date)
        let useCase = MockAlbumListUseCase(albums: [favouriteAlbum, gifAlbum, rawAlbum,
                                                    userAlbum1, userAlbum2, userAlbum3, userAlbum4, userAlbum5])

        let sut = AlbumListViewModel(usecase: useCase, albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(),
                                     featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: true]))
        
        sut.loadAlbums()
        await sut.albumLoadingTask?.value
        XCTAssertEqual(sut.albums, [
            favouriteAlbum.update(name: Strings.Localizable.CameraUploads.Albums.Favourites.title),
            gifAlbum.update(name: Strings.Localizable.CameraUploads.Albums.Gif.title),
            rawAlbum.update(name: Strings.Localizable.CameraUploads.Albums.Raw.title),
            userAlbum5,
            userAlbum4,
            userAlbum3,
            userAlbum2,
            userAlbum1
        ])
    }
    
    func testLoadAlbums_withCreateFeatureFlagTurnedOff_shouldOnlyLoadSystemAlbums() async throws {
        let favouriteAlbum = AlbumEntity(id: 1, name: "", coverNode: NodeEntity(handle: 1), count: 1, type: .favourite)
        let gifAlbum = AlbumEntity(id: 2, name: "", coverNode: NodeEntity(handle: 1), count: 1, type: .gif)
        let rawAlbum = AlbumEntity(id: 3, name: "", coverNode: NodeEntity(handle: 2), count: 1, type: .raw)
        let userAlbum = AlbumEntity(id: 4, name: "Album 1", coverNode: NodeEntity(handle: 3),
                                    count: 1, type: .user)
        let useCase = MockAlbumListUseCase(albums: [favouriteAlbum, gifAlbum, rawAlbum,
                                                    userAlbum])
        let sut = AlbumListViewModel(usecase: useCase, albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(),
                                     featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: false]))
        
        sut.loadAlbums()
        await sut.albumLoadingTask?.value
        XCTAssertEqual(sut.albums, [
            favouriteAlbum.update(name: Strings.Localizable.CameraUploads.Albums.Favourites.title),
            gifAlbum.update(name: Strings.Localizable.CameraUploads.Albums.Gif.title),
            rawAlbum.update(name: Strings.Localizable.CameraUploads.Albums.Raw.title)
        ])
    }
    
    func testLoadAlbums_onAlbumsLoadedFinsihed_shouldLoadSetToFalse() async throws {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(),
                                     featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: false]))
        let exp = expectation(description: "should load set after album load")
        
        sut.$shouldLoad
            .dropFirst()
            .sink {
                XCTAssertFalse($0)
                exp.fulfill()
            }.store(in: &subscriptions)
        
        sut.loadAlbums()
        await sut.albumLoadingTask?.value
        await fulfillment(of: [exp], timeout: 1.0)
    }
    
    func testHasCustomAlbum_whenUserLoadAlbums_shouldReturnTrue() async throws {
        let rawAlbum = AlbumEntity(id: 3, name: "", coverNode: NodeEntity(handle: 2), count: 1, type: .raw)
        let userAlbum1 = AlbumEntity(id: 4, name: "Album 1", coverNode: NodeEntity(handle: 3),
                                     count: 1, type: .user)
        let mockAlbumUseCase = MockAlbumListUseCase(albums: [rawAlbum, userAlbum1])
                                     
        let photoAlbumContainerViewModel = PhotoAlbumContainerViewModel()
        let sut = AlbumListViewModel(usecase: mockAlbumUseCase, albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(),
                                     photoAlbumContainerViewModel: photoAlbumContainerViewModel,
                                     featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: true]))
        
        sut.loadAlbums()
        await sut.albumLoadingTask?.value
        
        XCTAssertTrue(photoAlbumContainerViewModel.shouldShowSelectBarButton)
    }
    
    func testCreateUserAlbum_shouldCreateUserAlbum() {
        let exp = expectation(description: "Create a new user album")
        let useCase = MockAlbumListUseCase()
        let sut = AlbumListViewModel(usecase: useCase, albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(),
                                     featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: true]))
        sut.createUserAlbum(with: "userAlbum")
        sut.$shouldLoad
            .dropFirst()
            .sink {
                XCTAssertFalse($0)
                exp.fulfill()
            }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2.0)
    }
    
    func testHasCustomAlbum_whenUserCreateNewAlbum_shouldReturnTrue() {
        let exp = expectation(description: "Should set hasCustomAlbut to true when user create a new album")
        let photoAlbumContainerViewModel = PhotoAlbumContainerViewModel()
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(),
                                     photoAlbumContainerViewModel: photoAlbumContainerViewModel,
                                     featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: true]))
        sut.createUserAlbum(with: "userAlbum")
        sut.$shouldLoad
            .dropFirst()
            .sink {
                XCTAssertFalse($0)
                exp.fulfill()
            }.store(in: &subscriptions)
        
        wait(for: [exp], timeout: 2.0)
        XCTAssertTrue(photoAlbumContainerViewModel.shouldShowSelectBarButton)
    }
    
    func testCreateUserAlbum_whenUserCreatingAnAlbum_setShouldShowSelectBarButtonToFalse() async throws {
        let newAlbumName = "New Album"
        let newUserAlbum = AlbumEntity(id: 1, name: newAlbumName, coverNode: nil,
                                       count: 0, type: .user, modificationTime: try "2023-01-16T11:01:04Z".date)
        let useCase = MockAlbumListUseCase(albums: [], createdUserAlbums: [newAlbumName: newUserAlbum])
        
        let photoAlbumContainerViewModel = PhotoAlbumContainerViewModel()
        let sut = AlbumListViewModel(usecase: useCase, albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(), photoAlbumContainerViewModel: photoAlbumContainerViewModel)

        sut.createUserAlbum(with: newAlbumName)
        XCTAssertTrue(photoAlbumContainerViewModel.disableSelectBarButton)
        await sut.createAlbumTask?.value
        XCTAssertFalse(photoAlbumContainerViewModel.disableSelectBarButton)
    }
    
    func testNewAlbumName_whenAlbumContainsNoNewAlbum() async {
        let useCase = MockAlbumListUseCase()
        let sut = AlbumListViewModel(usecase: useCase, albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(),
                                     featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: true]))
        sut.loadAlbums()
        await sut.albumLoadingTask?.value
        XCTAssertEqual(sut.newAlbumName(), Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder)
    }
    
    func testNewAlbumName_whenAlbumContainsNewAlbum() async {
        let newAlbum = MockAlbumListUseCase.sampleUserAlbum(name: Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder)
        let useCase = MockAlbumListUseCase(albums: [newAlbum])
        let sut = AlbumListViewModel(usecase: useCase, albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(),
                                     featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: true]))
        sut.loadAlbums()
        await sut.albumLoadingTask?.value
        XCTAssertEqual(sut.albums.count, 1)
        XCTAssertEqual(sut.newAlbumName(), Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder + " \("(1)")")
    }
    
    func testNewAlbumName_whenAlbumContainsSomeNewAlbums_shouldReturnTheCorrectSuffix() async {
        let newAlbum = MockAlbumListUseCase.sampleUserAlbum(name: Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder)
        let newAlbum1 = MockAlbumListUseCase.sampleUserAlbum(name: Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder + " (1)")
        
        let newAlbum3 = MockAlbumListUseCase.sampleUserAlbum(name: Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder + " (3)")
        
        let newAlbum4 = MockAlbumListUseCase.sampleUserAlbum(name: Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder + "Some Random name")
        
        let useCase = MockAlbumListUseCase(albums: [newAlbum4, newAlbum, newAlbum1, newAlbum3])
        let sut = AlbumListViewModel(usecase: useCase, albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(),
                                     featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: true]))
        sut.loadAlbums()
        await sut.albumLoadingTask?.value
        
        let newAlbumNameShouldBe = Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder + " (2)"
        
        XCTAssertEqual(sut.newAlbumName(), newAlbumNameShouldBe)
    }
    
    func testNewAlbumName_whenAlbumContainsSomeNewAlbumsButNotNewAlbum_shouldReturnNewAlbum() async {
        let newAlbum1 = MockAlbumListUseCase.sampleUserAlbum(name: Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder + " (1)")
        
        let newAlbum3 = MockAlbumListUseCase.sampleUserAlbum(name: Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder + " (3)")
        
        let newAlbum4 = MockAlbumListUseCase.sampleUserAlbum(name: Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder + "Some Random name")
        
        let useCase = MockAlbumListUseCase(albums: [newAlbum4, newAlbum1, newAlbum3])
        let sut = AlbumListViewModel(usecase: useCase, albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(),
                                     featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: true]))
        sut.loadAlbums()
        await sut.albumLoadingTask?.value
        
        let newAlbumNameShouldBe = Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder
        
        XCTAssertEqual(sut.newAlbumName(), newAlbumNameShouldBe)
    }
    
    func testNewAlbumNamePlaceholderText_whenAlbumContainsNewAlbum_shouldReturnCounterSuffix() async {
        let newAlbum = MockAlbumListUseCase.sampleUserAlbum(name: Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder)
        let useCase = MockAlbumListUseCase(albums: [newAlbum])
        let sut = AlbumListViewModel(usecase: useCase, albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(),
                                     featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: true]))
        sut.loadAlbums()
        await sut.albumLoadingTask?.value
        sut.showCreateAlbumAlert = true
        
        XCTAssertEqual(sut.alertViewModel.placeholderText, "New album (1)")
    }
    
    func testValidateAlbum_whenAlbumNameIsNil_returnsNil() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel())
        XCTAssertNil(sut.alertViewModel.validator?(nil))
    }
    
    func testValidateAlbum_whenAlbumNameIsEmpty_returnsNil() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel())
        XCTAssertNil(sut.alertViewModel.validator?(""))
    }
    
    func testValidateAlbum_whenAlbumNameIsSpaces_returnsError() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel())
        XCTAssertNotNil(sut.alertViewModel.validator?("      "))
    }
    
    func testValidateAlbum_whenAlbumNameIsValidButWithWhiteSpaces_returnsNil() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel())
        XCTAssertNil(sut.alertViewModel.validator?("  userAlbum    "))
    }
    
    func testValidateAlbum_whenAlbumNameIsValid_returnsNil() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel())
        XCTAssertNil(sut.alertViewModel.validator?("userAlbum"))
    }
    
    func testValidateAlbum_whenAlbumNameContainsInvalidChars_returnsErrorMessage() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel())
        XCTAssertNotNil(sut.alertViewModel.validator?("userAlbum:/;"))
    }
    
    func testValidateAlbum_whenAlbumNameIsSameAsExistingUserAlbum_returnsErrorMessage() async {
        let newAlbum = MockAlbumListUseCase.sampleUserAlbum(name: "userAlbum")
        let useCase = MockAlbumListUseCase(albums: [newAlbum])
        let sut = AlbumListViewModel(usecase: useCase, albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(),
                                     featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: true]))
        sut.loadAlbums()
        await sut.albumLoadingTask?.value
        XCTAssertEqual(sut.albums.count, 1)
        XCTAssertNotNil(sut.alertViewModel.validator?(newAlbum.name))
    }
    
    func testValidateAlbum_whenAlbumNameIsSameAsExistingSystemAlbum_returnsErrorMessage() async {
        let newSysAlbum = AlbumEntity(id: AlbumIdEntity.favourite.rawValue, name: Strings.Localizable.CameraUploads.Albums.Favourites.title,
                                      coverNode: NodeEntity(handle: AlbumIdEntity.favourite.rawValue), count: 0, type: .favourite)
        let useCase = MockAlbumListUseCase(albums: [newSysAlbum])
        let sut = AlbumListViewModel(usecase: useCase, albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(),
                                     featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: true]))
        sut.loadAlbums()
        await sut.albumLoadingTask?.value
        XCTAssertEqual(sut.albums.count, 1)
        XCTAssertNotNil(sut.alertViewModel.validator?(newSysAlbum.name))
    }
    
    func testOnAlbumContentAdded_whenContentAddedInNewAlbum_shouldReloadAlbums() async {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel())

        let sampleAlbum = AlbumEntity(id: 1, name: "hello", coverNode: nil, count: 0, type: .user)
        let nodes = [NodeEntity(handle: 1)]
        sut.onNewAlbumContentAdded(sampleAlbum, photos: nodes)
        
        XCTAssertEqual(sut.newAlbumContent?.0, sampleAlbum)
        XCTAssertEqual(sut.newAlbumContent?.1, nodes)
    }
    
    func testValidateAlbum_withSystemAlbumNames_returnsErrorMessage() {
        let reservedNames = [Strings.Localizable.CameraUploads.Albums.Favourites.title,
                             Strings.Localizable.CameraUploads.Albums.Gif.title,
                             Strings.Localizable.CameraUploads.Albums.Raw.title,
                             Strings.Localizable.CameraUploads.Albums.MyAlbum.title,
                             Strings.Localizable.CameraUploads.Albums.SharedAlbum.title]
        let useCase = MockAlbumListUseCase()
        let sut = AlbumListViewModel(usecase: useCase, albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel())
        reservedNames.forEach { name in
            XCTAssertNotNil(sut.alertViewModel.validator?(name))
        }
    }
    
    func testColumns_createFeatureFlagIsOffThatThreeColumsReturn() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(), featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: false]))
        let result = sut.columns(horizontalSizeClass: .regular)
        XCTAssertEqual(result.count, 3)
    }
    
    func testColumns_sizeConfigurationsChangesReturnCorrectColumnsWhenCreateAlbumFeatureIsTurnedOn() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(), featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: true]))
        XCTAssertEqual(sut.columns(horizontalSizeClass: .compact).count, 3)
        XCTAssertEqual(sut.columns(horizontalSizeClass: nil).count, 3)
        XCTAssertEqual(sut.columns(horizontalSizeClass: .regular).count, 5)
    }
    
    func testNavigateToNewAlbum_onNewAlbumContentAdded_shouldNavigateToAlbumContentIfSet() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel())
        let userAlbum = AlbumEntity(id: 1, name: "User", coverNode: nil, count: 0, type: .user)
        let newAlbumPhotos = [NodeEntity(name: "a.jpg", handle: 1),
                              NodeEntity(name: "b.jpg", handle: 2)]
        sut.onNewAlbumContentAdded(userAlbum, photos: newAlbumPhotos)
        sut.navigateToNewAlbum()
        XCTAssertEqual(sut.album, userAlbum)
        XCTAssertEqual(sut.newAlbumContent?.1, newAlbumPhotos)
    }
    
    func testNavigateToNewAlbum_onNewAlbumContentAddedNotCalled_shouldNotNavigate() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel())
        
        sut.navigateToNewAlbum()
        XCTAssertNil(sut.album)
        XCTAssertNil(sut.newAlbumContent)
    }
    
    func testOnAlbumTap_whenUserTap_shouldSetCorrectValues() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel())
        let gifAlbum = AlbumEntity(id: 2, name: "", coverNode: NodeEntity(handle: 1), count: 1, type: .gif)
        
        sut.onAlbumTap(gifAlbum)
        XCTAssertNil(sut.albumCreationAlertMsg)
        XCTAssertEqual(sut.album, gifAlbum)
    }
    
    func testOnCreateAlbum_whenIsEditModeActive_shouldReturnFalseForShowCreateAlbumAlert() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel())
        
        sut.selection.editMode = .active
        XCTAssertFalse(sut.showCreateAlbumAlert)
        sut.onCreateAlbum()
        XCTAssertFalse(sut.showCreateAlbumAlert)
    }
    
    func testOnCreateAlbum_whenIsEditModeNotActive_shouldToggleShowCreateAlbumAlert() {
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel())
        
        XCTAssertFalse(sut.showCreateAlbumAlert)
        sut.onCreateAlbum()
        XCTAssertTrue(sut.showCreateAlbumAlert)
    }
    
    func testAlbumNames_whenExistingAlbumNamesNeeded_shouldReturnAlbumNames() async {
        let album1 = AlbumEntity(id: 1, name: "Hey there", coverNode: nil, count: 0, type: .user)
        let album2 = AlbumEntity(id: 1, name: "", coverNode: nil, count: 0, type: .user)
        let album3 = AlbumEntity(id: 1, name: "Favourites", coverNode: nil, count: 0, type: .favourite)
        
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(albums: [album1, album2, album3]), albumModificationUseCase: MockAlbumModificationUseCase(), alertViewModel: alertViewModel(),
                                     featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: true]))
        sut.loadAlbums()
        await sut.albumLoadingTask?.value
        
        XCTAssertEqual(sut.albumNames.sorted(), ["Hey there", "", "Favourites"].sorted())
    }
    
    func testReloadUpdates_onAlbumsUpdateEmiited_shouldRealodAlbums() {
        let albums = [AlbumEntity(id: 4, name: "Album 1", coverNode: NodeEntity(handle: 3),
                                  count: 1, type: .user)]
        let albumsUpdatedPublisher = PassthroughSubject<Void, Never>()
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(albums: albums,
                                                                   albumsUpdatedPublisher: albumsUpdatedPublisher.eraseToAnyPublisher()),
                                     albumModificationUseCase: MockAlbumModificationUseCase(),
                                     alertViewModel: alertViewModel(),
                                     featureFlagProvider: MockFeatureFlagProvider(list: [.createAlbum: true]))
        XCTAssertTrue(sut.albums.isEmpty)
        
        let exp = expectation(description: "should retrieve albums")
        sut.$albums
            .dropFirst()
            .sink {
                XCTAssertEqual($0, albums)
                exp.fulfill()
            }.store(in: &subscriptions)
        
        albumsUpdatedPublisher.send()
        wait(for: [exp], timeout: 2.0)
    }
    
    func testShowDeleteAlbumAlert_whenUserTapOnDeleteButton_shouldSetShowDeleteAlbumAlertToTrue() {
        let photoAlbumContainerViewModel = PhotoAlbumContainerViewModel()
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(),
                                     albumModificationUseCase: MockAlbumModificationUseCase(),
                                     alertViewModel: alertViewModel(),
                                     photoAlbumContainerViewModel: photoAlbumContainerViewModel)
        
        XCTAssertFalse(sut.showDeleteAlbumAlert)
        photoAlbumContainerViewModel.showDeleteAlbumAlert = true
        XCTAssertTrue(sut.showDeleteAlbumAlert)
    }
    
    func testOnAlbumListDeleteConfirm_whenAlbumDeletedSuccessfully_shouldDeleteMultipleAlbums() async {
        let albums = [AlbumEntity(id: HandleEntity(1), name: "ABC", coverNode: nil, count: 1, type: .user),
                      AlbumEntity(id: HandleEntity(2), name: "DEF", coverNode: nil, count: 2, type: .user)]
        let photoAlbumContainerViewModel = PhotoAlbumContainerViewModel()
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(albums: albums),
                                     albumModificationUseCase: MockAlbumModificationUseCase(albums: albums),
                                     alertViewModel: alertViewModel(),
                                     photoAlbumContainerViewModel: photoAlbumContainerViewModel)
        
        XCTAssertNil(sut.albumDeletedSuccessMsg)
        
        sut.onAlbumListDeleteConfirm()
        
        await sut.deleteAlbumTask?.value
        
        let targetMsg = Strings.Localizable.CameraUploads.Albums.deleteAlbumSuccess(albums.count)
        
        XCTAssertEqual(sut.albumDeletedSuccessMsg, targetMsg)
        XCTAssertFalse(photoAlbumContainerViewModel.editMode.isEditing)
    }
    
    func testOnAlbumListDeleteConfirm_whenAlbumDeletedSuccessfully_shouldDeleteSingleAlbum() async {
        let albums = [AlbumEntity(id: HandleEntity(1), name: "ABC", coverNode: nil, count: 1, type: .user)]
        let photoAlbumContainerViewModel = PhotoAlbumContainerViewModel()
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(albums: albums),
                                     albumModificationUseCase: MockAlbumModificationUseCase(albums: albums),
                                     alertViewModel: alertViewModel(),
                                     photoAlbumContainerViewModel: photoAlbumContainerViewModel)
        
        XCTAssertNil(sut.albumDeletedSuccessMsg)
        
        sut.onAlbumListDeleteConfirm()
        await sut.deleteAlbumTask?.value
        
        let targetMsg = Strings.Localizable.CameraUploads.Albums.deleteAlbumSuccess(albums.count)
        
        XCTAssertEqual(sut.albumDeletedSuccessMsg, targetMsg)
        XCTAssertFalse(photoAlbumContainerViewModel.editMode.isEditing)
    }
    
    func testOnAlbumListDeleteConfirm_whenAlbumDeletedFailed_shouldDoNothing() async {
        let albums = [AlbumEntity(id: HandleEntity(1), name: "ABC", coverNode: nil, count: 1, type: .user)]
        let photoAlbumContainerViewModel = PhotoAlbumContainerViewModel()
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(),
                                     albumModificationUseCase: MockAlbumModificationUseCase(),
                                     alertViewModel: alertViewModel(),
                                     photoAlbumContainerViewModel: photoAlbumContainerViewModel)
        sut.selection.setSelectedAlbums(albums)
        
        XCTAssertNil(sut.albumDeletedSuccessMsg)
        
        sut.onAlbumListDeleteConfirm()
        await sut.deleteAlbumTask?.value
        
        XCTAssertNil(sut.albumDeletedSuccessMsg)
        XCTAssertFalse(photoAlbumContainerViewModel.editMode.isEditing)
    }
    
    func testNumOfSelectedAlbums_onAlbumSelectionChanged_shouldSetIsAlbumSelected() {
        let albums = [AlbumEntity(id: HandleEntity(1), name: "ABC", coverNode: nil, count: 1, type: .user)]
        let photoAlbumContainerViewModel = PhotoAlbumContainerViewModel()
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(),
                                     albumModificationUseCase: MockAlbumModificationUseCase(),
                                     alertViewModel: alertViewModel(),
                                     photoAlbumContainerViewModel: photoAlbumContainerViewModel)
        
        XCTAssertFalse(photoAlbumContainerViewModel.isAlbumsSelected)
        
        sut.selection.setSelectedAlbums(albums)
        XCTAssertTrue(photoAlbumContainerViewModel.isAlbumsSelected)
    }
    
    func testShowDeleteAlbumAlert_whenUserTapDeleteButton_shouldSetShowDeleteAlbumAlertToTrue() async {
        let photoAlbumContainerViewModel = PhotoAlbumContainerViewModel()
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(),
                                     albumModificationUseCase: MockAlbumModificationUseCase(),
                                     alertViewModel: alertViewModel(),
                                     photoAlbumContainerViewModel: photoAlbumContainerViewModel)
        
        photoAlbumContainerViewModel.showDeleteAlbumAlert = true
        XCTAssertTrue(sut.showDeleteAlbumAlert)
    }
    
    func testIsExportedAlbumSelected_onExportedAlbumSelected_shouldSetIsExportedAlbumSelected() {
        let photoAlbumContainerViewModel = PhotoAlbumContainerViewModel()
        let sut = AlbumListViewModel(usecase: MockAlbumListUseCase(),
                                     albumModificationUseCase: MockAlbumModificationUseCase(),
                                     alertViewModel: alertViewModel(),
                                     photoAlbumContainerViewModel: photoAlbumContainerViewModel)
        XCTAssertFalse(photoAlbumContainerViewModel.isExportedAlbumSelected)
        let exportedUserAlbum = AlbumEntity(id: 5, type: .user, sharedLinkStatus: .exported(true))
        sut.selection.setSelectedAlbums([exportedUserAlbum])
        XCTAssertTrue(photoAlbumContainerViewModel.isExportedAlbumSelected)
    }
    
    private func alertViewModel() -> TextFieldAlertViewModel {
        TextFieldAlertViewModel(title: Strings.Localizable.CameraUploads.Albums.Create.Alert.title,
                                                   placeholderText: Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder,
                                                   affirmativeButtonTitle: Strings.Localizable.createFolderButton,
                                                   message: nil)
    }
}
