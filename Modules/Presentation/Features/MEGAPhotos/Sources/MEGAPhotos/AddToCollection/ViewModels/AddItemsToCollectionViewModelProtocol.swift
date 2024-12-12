import Combine
import MEGADomain
import SwiftUI

@MainActor
protocol AddItemsToCollectionViewModelProtocol {
    var isAddButtonDisabled: AnyPublisher<Bool, Never> { get }
    var isItemsLoadedPublisher: AnyPublisher<Bool, Never> { get }
    func addItems(_ photos: [NodeEntity])
}
