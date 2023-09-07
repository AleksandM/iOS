import Foundation
import UIKit

/// Development only implementation, will be moved to SearchMocks on next MR once
/// we have actual results provider using real SDK
public struct NonProductionTestResultsProvider: SearchResultsProviding {
    public init() {}
    public func search(queryRequest: SearchQueryEntity) async throws -> SearchResultsEntity {
        
        var searchString = queryRequest.query
        if searchString == "" {
            // this is to mimic the behaviour of the real search when with empty string we show all contents
            // of the folder being searched
            searchString = "manyResults"
        }
        
        let results: [SearchResult] = Array(0...searchString.count).map {
            SearchResult(
                id: ResultId($0),
                title: "Result \($0)",
                description: "Description \($0)",
                properties: [],
                thumbnailImageData: {
                    // sample data to show any images
                    return UIImage(systemName: "signature")!.jpegData(compressionQuality: 100)!
                },
                type: .node
            )
        }
        
        return .init(
            results: results,
            chips: []
        )
    }
}