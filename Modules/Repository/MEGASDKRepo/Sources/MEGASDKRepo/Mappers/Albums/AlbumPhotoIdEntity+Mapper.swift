import MEGADomain
import MEGASdk

extension MEGASetElement {
    public func toAlbumPhotoIdEntity() -> AlbumPhotoIdEntity {
        AlbumPhotoIdEntity(setElement: self)
    }
}

extension Array where Element: MEGASetElement {
    public func toAlbumPhotoIdEntities() -> [AlbumPhotoIdEntity] {
        map { $0.toAlbumPhotoIdEntity() }
    }
}

fileprivate extension AlbumPhotoIdEntity {
    init(setElement: MEGASetElement) {
        self.init(
            albumId: setElement.ownerId,
            albumPhotoId: setElement.handle,
            nodeId: setElement.nodeId
        )
    }
}
