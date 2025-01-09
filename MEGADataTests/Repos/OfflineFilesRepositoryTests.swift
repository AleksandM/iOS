@testable import MEGA
import MEGADomain
import MEGASDKRepoMock
import Testing

struct OfflineFilesRepositoryTestSuite {
    private static let mockNodeHandle: HandleEntity = 123
    private static let testNodeName = "Test Node"
    private static let testOfflineURL = URL(string: "/mock/offline/path")
    private static let testLocalPath = "test/path"
    
    @Suite("OfflineFilesRepository offlineURL Tests")
    struct OfflineURLTests {
        @Test("When offlinePath exists, should return a valid URL")
        func whenOfflinePathExists_shouldReturnValidURL() throws {
            let (sut, _) = makeSUT(offlineURL: testOfflineURL)
            #expect(sut.offlineURL == testOfflineURL)
        }
        
        @Test("When offlinePath is nil, should return nil")
        func whenOfflinePathIsNil_shouldReturnNil() throws {
            let (sut, _) = makeSUT(offlineURL: nil)
            #expect(sut.offlineURL == nil)
        }
    }
    
    @Suite("OfflineFilesRepository createOfflineFile Tests")
    struct CreateOfflineFileTests {
        @Test("With a valid node handle, should insert an offline node")
        func withValidNode_shouldInsertOfflineNode() throws {
            let mockNode = MockNode(handle: mockNodeHandle,
                                    name: testNodeName)
            let sdk = MockSdk(nodes: [mockNode])
            let (sut, mockStore) = makeSUT(sdk: sdk)
            
            sut.createOfflineFile(
                name: testLocalPath,
                for: mockNodeHandle
            )
            
            #expect(mockStore.insertOfflineNode_calledTimes == 1)
            #expect(mockStore.insertOfflineNode_lastPath == testLocalPath)
        }
        
        @Test("With an invalid node handle, should not insert an offline node")
        func withInvalidNode_shouldNotInsertOfflineNode() throws {
            let sdk = MockSdk(nodes: [])
            let (sut, mockStore) = makeSUT(sdk: sdk)
            
            sut.createOfflineFile(
                name: testLocalPath,
                for: mockNodeHandle
            )
            
            #expect(mockStore.insertOfflineNode_calledTimes == 0)
        }
    }
    
    @Suite("OfflineFilesRepository removeAllStoredOfflineNodes Tests")
    struct RemoveAllOfflineNodesTests {
        @Test("With a valid path, should call store")
        func withValidPath_shouldRemoveContentsAndCallStore() async throws {
            let mockNode = MockNode(
                handle: mockNodeHandle,
                name: testNodeName
            )
            let sdk = MockSdk(nodes: [mockNode])
            let (sut, mockStore) = makeSUT(
                sdk: sdk,
                fileManager: MockFileManager(contentsOfDirectory: ["test"]),
                offlineURL: testOfflineURL
            )
            
            sut.removeAllStoredOfflineNodes()
            
            #expect(mockStore.removeAllOfflineNodes_calledTimes == 1)
        }
    }
    
    private static func makeSUT(
        sdk: MockSdk = MockSdk(),
        fileManager: FileManager = MockFileManager(),
        offlineURL: URL? = testOfflineURL
    ) -> (OfflineFilesRepository, MockMEGAStore) {
        let store = MockMEGAStore()
        let sut = OfflineFilesRepository(
            store: store,
            offlineURL: offlineURL,
            sdk: sdk
        )
        return (sut, store)
    }
}
