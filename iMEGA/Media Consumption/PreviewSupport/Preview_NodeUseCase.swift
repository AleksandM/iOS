import MEGADomain

struct Preview_NodeUseCase: NodeUseCaseProtocol {
    func nodeAccessLevel(nodeHandle: HandleEntity) -> NodeAccessTypeEntity {
        .unknown
    }
    
    func nodeAccessLevelAsync(nodeHandle: HandleEntity) async -> NodeAccessTypeEntity {
        .unknown
    }
    
    func labelString(label: NodeLabelTypeEntity) -> String {
        ""
    }
    
    func getFilesAndFolders(nodeHandle: HandleEntity) -> (childFileCount: Int, childFolderCount: Int) {
        (0, 0)
    }
    
    func sizeFor(node: NodeEntity) -> UInt64? {
        nil
    }
    
    func folderInfo(node: NodeEntity) async throws -> FolderInfoEntity? {
        nil
    }
    
    func hasVersions(nodeHandle: HandleEntity) -> Bool {
        false
    }
    
    func isDownloaded(nodeHandle: HandleEntity) -> Bool {
        false
    }
    
    func isARubbishBinRootNode(nodeHandle: HandleEntity) -> Bool {
        false
    }
    
    func isInRubbishBin(nodeHandle: HandleEntity) -> Bool {
        false
    }
    
    func nodeForHandle(_ handle: HandleEntity) -> NodeEntity? {
        nil
    }
    
    func parentForHandle(_ handle: HandleEntity) -> NodeEntity? {
        nil
    }
    
    func parentsForHandle(_ handle: HandleEntity) async -> [NodeEntity]? {
        nil
    }
    
    func asyncChildrenOf(node: NodeEntity, sortOrder: SortOrderEntity) async -> NodeListEntity? {
        nil
    }
    
    func childrenOf(node: NodeEntity) -> NodeListEntity? {
        nil
    }
    
    func childrenNamesOf(node: NodeEntity) -> [String]? {
        nil
    }
    
    func isRubbishBinRoot(node: NodeEntity) -> Bool {
        false
    }
    
    func isRestorable(node: NodeEntity) -> Bool {
        false
    }
    
    func createFolder(with name: String, in parent: NodeEntity) async throws -> NodeEntity {
        throw GenericErrorEntity()
    }
}
