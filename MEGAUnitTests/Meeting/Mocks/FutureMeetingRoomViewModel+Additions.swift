@testable import MEGA
import MEGADomain
import MEGADomainMock
import MEGAPresentation
import MEGAPresentationMock

extension FutureMeetingRoomViewModel {
    convenience init(
        scheduledMeeting: ScheduledMeetingEntity = ScheduledMeetingEntity(),
        nextOccurrence: ScheduledMeetingOccurrenceEntity? = nil,
        router: some ChatRoomsListRouting = MockChatRoomsListRouter(),
        chatRoomUseCase: some ChatRoomUseCaseProtocol = MockChatRoomUseCase(),
        chatRoomUserUseCase: some ChatRoomUserUseCaseProtocol = MockChatRoomUserUseCase(),
        userImageUseCase: some UserImageUseCaseProtocol = MockUserImageUseCase(),
        chatUseCase: some ChatUseCaseProtocol = MockChatUseCase(),
        accountUseCase: some AccountUseCaseProtocol = MockAccountUseCase(),
        callUseCase: some CallUseCaseProtocol = MockCallUseCase(),
        audioSessionUseCase: some AudioSessionUseCaseProtocol = MockAudioSessionUseCase(),
        scheduledMeetingUseCase: some ScheduledMeetingUseCaseProtocol = MockScheduledMeetingUseCase(),
        megaHandleUseCase: some MEGAHandleUseCaseProtocol = MockMEGAHandleUseCase(),
        callManager: some CallManagerProtocol = MockCallManager(),
        permissionAlertRouter: MockPermissionAlertRouter? = nil,
        tracker: some AnalyticsTracking = MockTracker(),
        chatNotificationControl: ChatNotificationControl? = nil,
        chatListItemCacheUseCase: some ChatListItemCacheUseCaseProtocol = MockChatListItemCacheUseCase(),
        chatListItemAvatar: ChatListItemAvatarEntity? = nil,
        callInProgressTimeReporter: some CallInProgressTimeReporting = MockCallInProgressTimeReporter(),
        isTesting: Bool = true
    ) {
        let _permissionAlertRouter = if let permissionAlertRouter {
            permissionAlertRouter
        } else {
            MockPermissionAlertRouter()
        }
        self.init(
            scheduledMeeting: scheduledMeeting,
            nextOccurrence: nextOccurrence,
            router: router,
            chatRoomUseCase: chatRoomUseCase,
            chatRoomUserUseCase: chatRoomUserUseCase,
            userImageUseCase: userImageUseCase,
            chatUseCase: chatUseCase,
            accountUseCase: accountUseCase,
            callUseCase: callUseCase,
            audioSessionUseCase: audioSessionUseCase,
            scheduledMeetingUseCase: scheduledMeetingUseCase,
            megaHandleUseCase: megaHandleUseCase,
            callManager: callManager,
            permissionAlertRouter: _permissionAlertRouter,
            tracker: tracker,
            chatNotificationControl: chatNotificationControl ?? ChatNotificationControl(delegate: MockPushNotificationControl()),
            chatListItemCacheUseCase: chatListItemCacheUseCase,
            chatListItemAvatar: chatListItemAvatar,
            callInProgressTimeReporter: callInProgressTimeReporter
        )
    }
}
