import SwiftUI
import Combine
import MEGAUIKit

final class ChatRoomsListViewController: UIViewController {
    lazy var addBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: Asset.Images.NavigationBar.add.image, style: .plain, target: nil, action: nil)
    
    lazy var moreBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: Asset.Images.NavigationBar.moreNavigationBar.image, style: .plain, target: nil, action: nil)
    
    private(set) var viewModel: ChatRoomsListViewModel

    private var subscriptions = Set<AnyCancellable>()

    init(viewModel: ChatRoomsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureListView()
        updateTitleView()
        initSubscriptions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [moreBarButtonItem, addBarButtonItem]
        configureNavigationBarButtons(chatViewMode: viewModel.chatViewMode)
        viewModel.refreshMyAvatar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AudioPlayerManager.shared.addDelegate(self)
        viewModel.askForNotificationsPermissionsIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AudioPlayerManager.shared.removeDelegate(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureListView() {
        let hostingView = UIHostingController(rootView: ChatRoomsListView(viewModel: viewModel))
        addChild(hostingView)
        view.addSubview(hostingView.view)
        hostingView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostingView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            hostingView.view.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        hostingView.didMove(toParent: self)
    }
    
    private func updateTitleView() {
        if let statusString = viewModel.chatStatus?.toChatStatus().localizedIdentifier {
            navigationItem.titleView = UILabel().customNavigationBarLabel(title: viewModel.title, subtitle: statusString)
        } else {
            navigationItem.title = viewModel.title
        }
    }
    
    private func initSubscriptions() {
        viewModel.refreshContextMenuBarButton = { [weak self] in self?.refreshContextMenuBarButton() }
        subscriptions = [
            viewModel.$chatViewMode.sink(receiveValue: { [weak self] chatViewMode in
                self?.configureNavigationBarButtons(chatViewMode: chatViewMode)
            }),
            viewModel.$chatStatus.sink(receiveValue: { [weak self] _ in
                self?.refreshContextMenuBarButton()
                self?.updateTitleView()
            }),
            viewModel.$myAvatarBarButton.sink(receiveValue: { [weak self] myAvatarBarButton in
                self?.navigationItem.leftBarButtonItem = myAvatarBarButton
            }),
            viewModel.$isConnectedToNetwork.sink(receiveValue: { [weak self] isConnectedToNetwork in
                self?.addBarButtonItem.isEnabled = isConnectedToNetwork
                self?.updateTitleView()
            })
        ]
    }
    
    @objc func addBarButtonItemTapped() {
        viewModel.addChatButtonTapped()
    }
    
    func updateBackBarButtonItem(withUnreadMessages count: Int) {
        guard count > 0 else {
            clearBackBarButtonItem()
            return
        }
        
        let title = String(format: "(%td)", count)
        let backBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    private func clearBackBarButtonItem() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

extension ChatRoomsListViewController: AudioPlayerPresenterProtocol {
    func updateContentView(_ height: CGFloat) {
        viewModel.bottomViewHeight = height
    }
}
