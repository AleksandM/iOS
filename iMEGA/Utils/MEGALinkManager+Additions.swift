import Accounts
import ChatRepo
import MEGADomain
import MEGAL10n
import MEGAPermissions
import MEGAPresentation
import MEGASdk
import MEGASDKRepo
import SwiftUI
import UserNotifications

extension MEGALinkManager {
    @objc class func downloadFileLinkAfterLogin() {
        guard let linkUrl = URL(string: MEGALinkManager.linkSavedString) else { return }
        let transferViewEntity = CancellableTransfer(fileLinkURL: linkUrl, name: nil, appData: nil, priority: false, isFile: true, type: .downloadFileLink)
        CancellableTransferRouter(presenter: UIApplication.mnz_visibleViewController(), transfers: [transferViewEntity], transferType: .downloadFileLink).start()
    }
    
    @objc class func downloadFolderLinkAfterLogin() {
        guard let nodes = nodesFromLinkMutableArray as? [MEGANode] else {
            return
        }
        let transfers = nodes.map { CancellableTransfer(handle: $0.handle, name: nil, appData: nil, priority: false, isFile: $0.isFile(), type: .download) }
        CancellableTransferRouter(presenter: UIApplication.mnz_visibleViewController(), transfers: transfers, transferType: .download, isFolderLink: true).start()
    }
    
    @objc class func openBrowser(by urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        UIApplication.shared.open(url)
    }
    
    class func nodesFromLinkToDownloadAfterLogin(nodes: [NodeEntity]) {
        MEGALinkManager.nodesFromLinkMutableArray.addObjects(from: nodes.toMEGANodes(in: .sharedFolderLinkSdk))
    }
    
    @objc class func showCollectionLinkView() {
        guard DIContainer.featureFlagProvider.isFeatureFlagEnabled(for: .albumShareLink) else { return }
        guard let publicLink = albumPublicLink() else {
            MEGALinkManager.showLinkNotValid()
            return
        }
        let sdk: MEGASdk = .sharedSdk
        let nodeProvider: some PublicAlbumNodeProviderProtocol = PublicAlbumNodeProvider.shared
        let userAlbumRepository = UserAlbumRepository.newRepo
        let shareAlbumRepository = ShareAlbumRepository(
            sdk: sdk,
            publicAlbumNodeProvider: nodeProvider)
        
        let nodeRepository: NodeRepository = .newRepo
        
        let importAlbumUseCase = ImportPublicAlbumUseCase(
            saveAlbumToFolderUseCase: SaveAlbumToFolderUseCase(
                nodeActionRepository: NodeActionRepository.newRepo,
                shareAlbumRepository: shareAlbumRepository,
                nodeRepository: nodeRepository),
            userAlbumRepository: userAlbumRepository)
        
        let vm = ImportAlbumViewModel(
            publicLink: publicLink,
            publicAlbumUseCase: PublicAlbumUseCase(
                shareAlbumRepository: shareAlbumRepository),
            albumNameUseCase: AlbumNameUseCase(
                userAlbumRepository: UserAlbumRepository.newRepo),
            accountStorageUseCase: AccountStorageUseCase(accountRepository: AccountRepository.newRepo),
            importPublicAlbumUseCase: importAlbumUseCase,
            accountUseCase: AccountUseCase(
                repository: AccountRepository.newRepo),
            saveMediaUseCase: SaveMediaToPhotosUseCase(
                downloadFileRepository: DownloadFileRepository(
                    sdk: sdk,
                    nodeProvider: nodeProvider),
                fileCacheRepository: FileCacheRepository.newRepo,
                nodeRepository: nodeRepository),
            transferWidgetResponder: TransfersWidgetViewController.sharedTransfer(),
            permissionHandler: DevicePermissionsHandler.makeHandler(),
            tracker: DIContainer.tracker,
            monitorUseCase: NetworkMonitorUseCase(repo: NetworkMonitorRepository.newRepo))
        
        let viewController = UIHostingController(dismissibleView: ImportAlbumView(
            viewModel: vm))
        viewController.modalPresentationStyle = .fullScreen
        UIApplication.mnz_visibleViewController().present(viewController, animated: true)
    }
    
    class func albumPublicLink() -> URL? {
        guard let link = MEGALinkManager.linkURL else { return nil }
        guard link.scheme == "mega" else {
            return link
        }
        var components = URLComponents()
        components.scheme = "https"
        components.host = "mega.nz"
        var startingPath = ""
        if let host = link.host {
            startingPath = "/" + host
        }
        components.path = startingPath + link.path
        components.fragment = link.fragment
        return components.url
    }
    
    @objc
    class func continueWith(
        chatId: UInt64,
        chatTitle: String,
        chatLink: URL,
        shouldAskForNotificationsPermissions: Bool,
        permissionHandler: DevicePermissionsHandlerObjC
    ) {
        guard let identifier = MEGASdk.base64Handle(forHandle: chatId) else {
            // does it make sense to handle this error apart from early return?
            return
        }
        let notificationText = String(format: Strings.localized("You have joined %@", comment: "Text shown in a notification to let the user know that has joined a public chat room after login or account creation"), chatTitle)
        
        if shouldAskForNotificationsPermissions {
            SVProgressHUD.showSuccess(withStatus: notificationText)
            return
        }
        
        permissionHandler.notificationsPermission {granted in
            if !granted {
                SVProgressHUD.showSuccess(withStatus: notificationText)
            }
            
            MEGALinkManager.createChatAndShow(chatId, publicChatLink: chatLink)
            
            addNotficiation(
                notificationText: notificationText,
                chatId: chatId,
                identifier: identifier
            )
        }
    }
    
    static func addNotficiation(
        notificationText: String,
        chatId: UInt64,
        identifier: String
    ) {
        
        let content = UNMutableNotificationContent()
        content.body = notificationText
        content.sound = .default
        content.userInfo = ["chatId": chatId]
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { _ in
            SVProgressHUD.showSuccess(withStatus: notificationText)
        }
    }
    
    @objc class func initFullScreenPlayer(node: MEGANode?, fileLink: String?, filePaths: [String]?, isFolderLink: Bool, presenter: UIViewController) {
        AudioPlayerManager.shared.initFullScreenPlayer(
            node: node,
            fileLink: fileLink,
            filePaths: filePaths,
            isFolderLink: isFolderLink,
            presenter: presenter,
            messageId: .invalid,
            chatId: .invalid,
            allNodes: nil
        )
    }
    
    @objc class func hasActiveMeeting(for request: MEGAChatRequest) -> Bool {
        let list = request.megaHandleList
        guard let list else { return false }
        return list.size > 0 && list.megaHandle(at: 0) != 0
    }
    
    @objc class func shouldOpenWaitingRoom(request: MEGAChatRequest, chatSdk: MEGAChatSdk = .shared) -> Bool {
        guard let megaChatRoom = chatSdk.chatRoom(forChatId: request.chatHandle) else { return false }
        let (isModerator, isWaitingRoomEnabled) = meetingInfo(for: megaChatRoom.toChatRoomEntity(), request: request, chatSdk: chatSdk)
        return !isModerator && isWaitingRoomEnabled
    }
    
    @objc class func openWaitingRoom(for chatId: ChatIdEntity, chatLink: String, requestUserHandle: HandleEntity) {
        guard let scheduledMeeting = MEGAChatSdk.shared.scheduledMeetings(byChat: chatId).first?.toScheduledMeetingEntity() else { return }
        let rootViewController = UIApplication.mnz_visibleViewController()
        guard !MEGAChatSdk.shared.mnz_existsActiveCall else {
            MeetingAlreadyExistsAlert.show(presenter: rootViewController)
            return
        }
        WaitingRoomViewRouter(
            presenter: rootViewController,
            scheduledMeeting: scheduledMeeting,
            chatLink: chatLink,
            requestUserHandle: requestUserHandle
        ).start()
    }
    
    @objc class func isHostInWaitingRoom(request: MEGAChatRequest, chatSdk: MEGAChatSdk = .shared) -> Bool {
        guard let megaChatRoom = chatSdk.chatRoom(forChatId: request.chatHandle) else { return false }
        let (isModerator, isWaitingRoomEnabled) = meetingInfo(for: megaChatRoom.toChatRoomEntity(), request: request, chatSdk: chatSdk)
        return isModerator && isWaitingRoomEnabled
    }
    
    private class func meetingInfo(for chatRoom: ChatRoomEntity, request: MEGAChatRequest, chatSdk: MEGAChatSdk) -> (Bool, Bool) {
        let isModerator = chatRoom.ownPrivilege == .moderator
        let isWaitingRoomEnabled = chatSdk.hasChatOptionEnabled(for: .waitingRoom, chatOptionsBitMask: request.privilege)
        return (isModerator, isWaitingRoomEnabled)
    }
    
    @objc class func joinCall(request: MEGAChatRequest) {
        let chatId = request.chatHandle
        guard let megaChatRoom = MEGAChatSdk.shared.chatRoom(forChatId: chatId) else {
            return
        }
        let chatRoom = megaChatRoom.toChatRoomEntity()
        let callUseCase = CallUseCase(repository: CallRepository.newRepo)
        Task { @MainActor in
            guard let callEntity = try? await callUseCase.answerCall(for: chatId, enableVideo: false, enableAudio: true) else {
                return
            }
            openCallUI(call: callEntity, chatRoom: chatRoom)
        }
    }
    
    @MainActor
    private class func openCallUI(call: CallEntity, chatRoom: ChatRoomEntity) {
        MeetingContainerRouter(presenter: UIApplication.mnz_presentingViewController(), chatRoom: chatRoom, call: call, isSpeakerEnabled: true).start()
    }
}

// MARK: - Ads
 extension MEGALinkManager {
     @objc class func presentViewControllerWithAds(_ containerController: UIViewController, adsSlotViewController: UIViewController) {
         guard let adsSlotViewController = adsSlotViewController as? (any AdsSlotViewControllerProtocol) else { return }
         AdsSlotRouter(
            adsSlotViewController: adsSlotViewController,
            contentView: AdsViewWrapper(viewController: containerController),
            presenter: UIApplication.mnz_visibleViewController()
         ).start()
     }
 }
