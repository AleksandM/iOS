
import WidgetKit
import SwiftUI

typealias EntryValue = (items: [QuickAccessItemModel], status: WidgetStatus)

struct QuickAccessWidgetEntry: TimelineEntry {
    let date: Date
    let section: String
    let link: String
    let value: EntryValue
    
    static func placeholder() -> QuickAccessWidgetEntry {
        QuickAccessWidgetEntry(date: Date(),
                               section: SectionDetail.defaultSection.title,
                               link: "mega://widget.quickaccess.reload",
                               value: ([QuickAccessItemModel(thumbnail: Image(Asset.Images.Filetypes.generic.name), name: "File.txt", url: URL(fileURLWithPath: "mega://widget.quickaccess.reload"), image: nil, description: nil)], .connected))
    }
}
