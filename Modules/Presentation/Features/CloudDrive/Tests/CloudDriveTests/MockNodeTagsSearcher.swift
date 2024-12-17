@testable import CloudDrive

actor MockNodeTagsSearcher: NodeTagsSearching {
    private var tags: [String]?
    var continuations: [CheckedContinuation<[String]?, Never>] = []

    init(tags: [String]? = []) {
        self.tags = tags
    }

    func update(tags: [String]?) {
        self.tags = tags
    }

    func searchTags(for searchText: String?) async -> [String]? {
        if let tags {
            guard let searchText else {
                return tags
            }

            return tags.filter { $0.contains(searchText) }
        } else {
            return await withCheckedContinuation { continuation in
                continuations.append(continuation)
            }
        }
    }
}
