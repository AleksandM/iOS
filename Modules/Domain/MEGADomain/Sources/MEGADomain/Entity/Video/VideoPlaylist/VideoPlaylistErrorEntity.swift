public enum VideoPlaylistErrorEntity: Error, Equatable {
    case invalidOperation
    case failedToAddVideoToPlaylist
    case failedToDeleteVideoPlaylistElements
    case failedToRetrieveSetFromRequest
    case failedToRetrieveNewlyCreatedPlaylist
    case failedToCreatePlaylist(name: String?)
    case videoPlaylistNotFound(id: HandleEntity)
    case failedToUpdateVideoPlaylistName(name: String)
    case noChangeWasNeeded
}
