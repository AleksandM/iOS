
import Foundation
import MEGADomain

protocol ManageChatHistoryProtocol {
    func didTap(on source: ManageChatHistoryRoutingSource)
}

enum ManageChatHistoryRoutingSource {
    case historyRetentionSwitch(UIAlertController)
    case clearChatHistoryAlert(UIAlertController)
}

final class ManageChatHistoryViewRouter: NSObject, ManageChatHistoryProtocol {
    private weak var baseViewController: UITableViewController?
    private weak var navigationController: UINavigationController?
    
    private let chatId: ChatId
    
    @objc init(chatId: ChatId, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.chatId = chatId
        
        super.init()
    }
    
    func build() -> UIViewController {
        let repository = ManageChatHistoryRepository(chatSdk: MEGASdkManager.sharedMEGAChatSdk())
        let manageChatHistoryUseCase = ManageChatHistoryUseCase(retentionValueUseCase: HistoryRetentionUseCase(repository: repository), historyRetentionUseCase: HistoryRetentionUseCase(repository: repository), clearChatHistoryUseCase: ClearChatHistoryUseCase(repository: repository))
        let viewModel = ManageChatHistoryViewModel(router: self, manageChatHistoryUseCase: manageChatHistoryUseCase, chatId: chatId)
        let pickerViewModel = HistoryRetentionPickerViewModel()
        
        let tableViewController = UIStoryboard(name: "ManageChatHistory", bundle: nil).instantiateViewController(withIdentifier: "ManageChatHistoryTableViewControllerID") as! ManageChatHistoryTableViewController
        tableViewController.viewModel = viewModel
        tableViewController.pickerViewModel = pickerViewModel
        tableViewController.router = self

        baseViewController = tableViewController

        return tableViewController
    }
    
    @objc func start() {
        navigationController?.pushViewController(build(), animated: true)
    }
    
    // MARK: - ManageChatHistoryProtocol
    
    func didTap(on source: ManageChatHistoryRoutingSource) {
        switch source {
        case .historyRetentionSwitch(let alertController):
            presentAlert(alertController)
            
        case .clearChatHistoryAlert(let alertController):
            presentAlert(alertController)
        }
    }
    
    // MARK: - Private
    
    private func presentAlert(_ alertController: UIAlertController) {
        navigationController?.present(alertController, animated: true, completion: nil)
    }
}
