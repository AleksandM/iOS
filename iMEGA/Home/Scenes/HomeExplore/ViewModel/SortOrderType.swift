
enum SortOrderType {
    case none
    case nameAscending
    case nameDescending
    case largest
    case smallest
    case newest
    case oldest
    case label
    case favourite
    
    static let allValid: [SortOrderType] = [
        .nameAscending,
        .nameDescending,
        .largest,
        .smallest,
        .newest,
        .oldest,
        .label,
        .favourite
    ]
    
    static func defaultSortOrderType(forNode node: MEGANode?) -> SortOrderType {
        return SortOrderType(megaSortOrderType: Helper.sortType(for: nil))
    }
    
    var localizedString: String {
        let key: String
        
        switch self {
        case .nameAscending:
            key = "nameAscending"
        case .nameDescending:
            key = "nameDescending"
        case .largest:
            key = "largest"
        case .smallest:
            key = "smallest"
        case .newest:
            key = "newest"
        case .oldest:
            key = "oldest"
        case .label:
            key = "Label"
        case .favourite:
            key = "Favourite"
        case .none:
            key = ""
        }
        
        return AMLocalizedString(key)
    }
    
    var image: UIImage? {
        let imageName: String
        
        switch self {
        case .nameAscending:
            imageName = "ascending"
        case .nameDescending:
            imageName = "descending"
        case .largest:
            imageName = "largest"
        case .smallest:
            imageName = "smallest"
        case .newest:
            imageName = "newest"
        case .oldest:
            imageName = "oldest"
        case .label:
            imageName = "label"
        case .favourite:
            imageName = "favourite"
        case .none:
            imageName = ""
        }
        
        return UIImage(named: imageName)
    }
    
    var megaSortOrderType: MEGASortOrderType {
        switch self {
        case .nameAscending :
            return .defaultAsc
        case .nameDescending:
            return .defaultDesc
        case .largest:
            return .sizeDesc
        case .smallest:
            return .sizeAsc
        case .newest:
            return .modificationDesc
        case .oldest:
            return .modificationAsc
        case .label:
            return .labelAsc
        case .favourite:
            return .favouriteAsc
        case .none:
            return .none
        }
    }
    
    init(megaSortOrderType: MEGASortOrderType) {
        switch megaSortOrderType {
        case .defaultAsc:
            self = .nameAscending
        case .defaultDesc:
            self = .nameDescending
        case .sizeDesc:
            self = .largest
        case .sizeAsc:
            self = .smallest
        case .modificationDesc:
            self = .newest
        case .modificationAsc:
            self = .oldest
        case .labelAsc:
            self = .label
        case .favouriteAsc:
            self = .favourite
        default:
            self = .none
        }
    }
}
