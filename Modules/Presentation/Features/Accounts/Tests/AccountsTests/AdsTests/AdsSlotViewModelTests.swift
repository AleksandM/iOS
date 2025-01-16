@testable import Accounts
import AccountsMock
import Combine
import MEGAAnalyticsiOS
import MEGADomain
import MEGADomainMock
import MEGAPresentation
import MEGAPresentationMock
import MEGASDKRepoMock
import MEGASwift
import MEGATest
import XCTest

final class AdsSlotViewModelTests: XCTestCase {
    private var subscriptions = Set<AnyCancellable>()
    private let notificationCenter = NotificationCenter()
    
    override func tearDown() {
        subscriptions.removeAll()
        super.tearDown()
    }
    
    // MARK: - Subscription
    @MainActor
    func testAccountDidPurchasedPlanNotif_purchasedAccountSuccessAndExternalAdsIsEnabled_shouldHideAds() async {
        await assertAccountDidPurchasedPlanNotif(isExternalAdsFlagEnabled: true)
    }
    
    @MainActor
    func testAccountDidPurchasedPlanNotif_purchasedAccountSuccessAndExternalAdsIsDisabled_shouldDoNothing() async {
        await assertAccountDidPurchasedPlanNotif(isExternalAdsFlagEnabled: false)
    }
    
    @MainActor private func assertAccountDidPurchasedPlanNotif(
        isExternalAdsFlagEnabled: Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let sut = makeSUT(isExternalAdsFlagEnabled: isExternalAdsFlagEnabled)
        await sut.setupAdsRemoteFlag()
        sut.setupSubscriptions()
        
        let expectedAdsFlag = isExternalAdsFlagEnabled ? false : isExternalAdsFlagEnabled
        
        let isExternalAdsEnabledExp = expectation(description: "isExternalAdsEnabled should be \(expectedAdsFlag)")
        isExternalAdsEnabledExp.isInverted = !isExternalAdsFlagEnabled
        sut.$isExternalAdsEnabled
            .dropFirst()
            .sink { _ in
                isExternalAdsEnabledExp.fulfill()
            }
            .store(in: &subscriptions)
        
        let displayAdsExp = expectation(description: "displayAds should be \(expectedAdsFlag)")
        displayAdsExp.isInverted = !isExternalAdsFlagEnabled
        sut.$displayAds
            .dropFirst()
            .sink { _ in
                displayAdsExp.fulfill()
            }
            .store(in: &subscriptions)
        
        let showAdsFreeViewExp = expectation(description: "showAdsFreeView should be \(expectedAdsFlag)")
        showAdsFreeViewExp.isInverted = !isExternalAdsFlagEnabled
        sut.$showAdsFreeView
            .dropFirst()
            .sink { _ in
                showAdsFreeViewExp.fulfill()
            }
            .store(in: &subscriptions)
        
        notificationCenter.post(name: .accountDidPurchasedPlan, object: nil)
        await fulfillment(of: [isExternalAdsEnabledExp, displayAdsExp, showAdsFreeViewExp], timeout: 1.0)

        XCTAssertEqual(sut.isExternalAdsEnabled, expectedAdsFlag, file: file, line: line)
        XCTAssertEqual(sut.displayAds, expectedAdsFlag, file: file, line: line)
        XCTAssertEqual(sut.showAdsFreeView, expectedAdsFlag, file: file, line: line)
    }
    
    @MainActor func testStartAdsNotification_shouldSetStartAdsToTrue() {
        let sut = makeSUT()
        sut.setupSubscriptions()
        
        let startAdsExp = expectation(description: "startAds should be true")
        sut.$startAds
            .dropFirst()
            .sink { _ in
                startAdsExp.fulfill()
            }
            .store(in: &subscriptions)
        
        notificationCenter.post(name: .startAds, object: nil)
        
        wait(for: [startAdsExp], timeout: 1.0)
        XCTAssertEqual(sut.startAds, true)
    }
    
    // MARK: - Ads slot
    @MainActor func testSetupAdsRemoteFlag_whenAccountIsNotFree_shouldDisableExternalAds() async throws {
        let billedAccountTypes = AccountTypeEntity.allCases.filter({ $0 != .free })
        for type in billedAccountTypes {
            let sut = makeSUT(accountDetailsResult: .success(AccountDetailsEntity.build(proLevel: type)))
            await sut.setupAdsRemoteFlag()
            let isExternalAdsEnabled = try XCTUnwrap(sut.isExternalAdsEnabled)
            XCTAssertFalse(isExternalAdsEnabled, "Account type \(type) should hide ads")
        }
    }
    
    @MainActor
    func testSetupAdsRemoteFlag_whenAccountIsFreeWithSuccessAccountDetailsResult_shouldMatchExternalAdsValue() async {
        await assertSetupAdsRemoteFlag(isLoggedIn: true, accountDetailsResult: .success(AccountDetailsEntity.build(proLevel: .free)))
    }
              
    @MainActor
    func testSetupAdsRemoteFlag_whenAccountIsFreeWithFailedAccountDetailsResult_shouldMatchExternalAdsValue() async {
        await assertSetupAdsRemoteFlag(isLoggedIn: true, accountDetailsResult: .failure(.generic))
    }
    
    @MainActor
    func testSetupAdsRemoteFlag_whenNoLoggedInUser_shouldMatchExternalAdsValue() async {
        await assertSetupAdsRemoteFlag(isLoggedIn: false)
    }
    
    @MainActor private func assertSetupAdsRemoteFlag(
        isLoggedIn: Bool = true,
        accountDetailsResult: Result<AccountDetailsEntity, AccountDetailsErrorEntity> = .success(AccountDetailsEntity.build(proLevel: .free)),
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let expectedExternalAdsValue = Bool.random()
        let sut = makeSUT(
            isExternalAdsFlagEnabled: expectedExternalAdsValue,
            accountDetailsResult: accountDetailsResult,
            isLoggedIn: isLoggedIn
        )
        
        await sut.setupAdsRemoteFlag()
        
        XCTAssertEqual(sut.isExternalAdsEnabled, expectedExternalAdsValue, file: file, line: line)
    }

    @MainActor func testUpdateAdsSlot_externalAdsDisabled_shouldHideAds() async {
        let sut = makeSUT(isExternalAdsFlagEnabled: false)
        
        await sut.setupAdsRemoteFlag()
        sut.updateAdsSlot(randomAdsSlotConfig)
        
        XCTAssertNil(sut.adsSlotConfig)
        XCTAssertFalse(sut.displayAds)
    }
    
    @MainActor func testUpdateAdsSlot_externalAdsIsNil_shouldSetAdsSlotConfig() async {
        let sut = makeSUT()
        
        XCTAssertNil(sut.isExternalAdsEnabled)
        
        let expectedAdsSlotConfig = randomAdsSlotConfig
        sut.updateAdsSlot(expectedAdsSlotConfig)
        
        XCTAssertEqual(sut.adsSlotConfig, expectedAdsSlotConfig)
        XCTAssertEqual(sut.displayAds, expectedAdsSlotConfig.displayAds)
    }
    
    @MainActor func testUpdateAdsSlot_externalAdsEnabledAndReceivedSameAdsSlot_withDifferentDisplayAdsValue_shouldHaveLatestDisplayAds() async {
        let randomAdSlot = randomAdsSlotConfig
        let expectedConfig = AdsSlotConfig(adsSlot: randomAdSlot.adsSlot, displayAds: true)
        
        await assertUpdateAdsSlotShouldDisplayAds(
            adsSlots: [
                AdsSlotConfig(adsSlot: randomAdSlot.adsSlot, displayAds: false),
                expectedConfig
            ],
            expectedLatestAdsSlotConfig: expectedConfig
        )
    }
    
    @MainActor
    func testUpdateAdsSlot_externalAdsEnabledAndReceivedSameAdsSlot_withSameDisplayAdsValue_shouldHaveTheSameDisplayAdsValue() async {
        let randomAdSlot = randomAdsSlotConfig
        
        await assertUpdateAdsSlotShouldDisplayAds(
            adsSlots: [randomAdSlot, randomAdSlot],
            expectedLatestAdsSlotConfig: randomAdSlot
        )
    }
    
    @MainActor
    func testUpdateAdsSlot_externalAdsEnabledAndReceivedNewAdSlot_withSameDisplayAdsValues_shouldDisplayAds() async {
        let randomAdSlot = randomAdsSlotConfig
        
        await assertUpdateAdsSlotShouldDisplayAds(
            adsSlots: [randomAdSlot],
            expectedLatestAdsSlotConfig: randomAdSlot
        )
    }
    
    @MainActor private func assertUpdateAdsSlotShouldDisplayAds(
        adsSlots: [AdsSlotConfig],
        expectedLatestAdsSlotConfig: AdsSlotConfig,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let adsSlotUpdates = MockAdsSlotUpdatesProvider(
            adsSlotUpdates: makeAdsSlotUpdatesStream(adsSlotConfigs: adsSlots).eraseToAnyAsyncSequence()
        )
        let sut = makeSUT(adsSlotUpdatesProvider: adsSlotUpdates, isExternalAdsFlagEnabled: true)
        
        // Set initial AdSlot
        sut.updateAdsSlot(randomAdsSlotConfig)
        
        // Monitor Ads slot changes
        await sut.setupAdsRemoteFlag()
        sut.startMonitoringAdsSlotUpdates()
        await sut.monitorAdsSlotUpdatesTask?.value
        
        XCTAssertEqual(sut.adsSlotConfig, expectedLatestAdsSlotConfig, file: file, line: line)
        XCTAssertEqual(sut.displayAds, expectedLatestAdsSlotConfig.displayAds, file: file, line: line)
    }
    
    @MainActor func testStopMonitoringAdsSlotUpdates_shouldCancelTask() async {
        let sut = makeSUT(isExternalAdsFlagEnabled: true)
        sut.startMonitoringAdsSlotUpdates()
        await sut.monitorAdsSlotUpdatesTask?.value
        
        sut.stopMonitoringAdsSlotUpdates()
        XCTAssertTrue(sut.monitorAdsSlotUpdatesTask?.isCancelled ?? false)
    }
    
    @MainActor func testAdMob_withTestEnvironment_shouldUseTestUnitID() {
        assertAdMob(
            forEnvs: AppConfigurationEntity.allCases.filter({ $0 != .production }),
            expectedAdMob: AdMob.test
        )
    }
    
    @MainActor func testAdMob_withLiveEnvironment_shouldUseLiveUnitID() {
        assertAdMob(
            forEnvs: [.production],
            expectedAdMob: AdMob.live
        )
    }
    
    @MainActor private func assertAdMob(forEnvs envs: [AppConfigurationEntity], expectedAdMob: AdMob) {
        let appEnvironmentUseCase = MockAppEnvironmentUseCase()
        let sut = makeSUT(appEnvironmentUseCase: appEnvironmentUseCase)
        
        envs.forEach { env in
            appEnvironmentUseCase.configuration = env
            XCTAssertEqual(sut.adMob, expectedAdMob, "\(env) environment should use the \(expectedAdMob) unit id")
        }
    }
    
    // MARK: - Close button
    
    @MainActor func testBannerViewDidReceiveAd_whenNoLoggedInUser_shouldSetShowCloseButtonToFalse() {
        assertShowCloseButton(isLoggedIn: false)
    }
    
    @MainActor func testBannerViewDidReceiveAd_whenUserIsLoggedIn_shouldSetShowCloseButtonToTrue() {
        assertShowCloseButton(isLoggedIn: true)
    }
    
    @MainActor private func assertShowCloseButton(isLoggedIn: Bool) {
        let sut = makeSUT(isLoggedIn: isLoggedIn)
        
        XCTAssertFalse(sut.showCloseButton)
        
        sut.bannerViewDidReceiveAd()
        
        XCTAssertEqual(sut.showCloseButton, isLoggedIn)
    }
    
    @MainActor func testDidTapCloseAdsButton_shouldSetShowAdsFreeViewToTrue() {
        let sut = makeSUT()
        
        sut.didTapCloseAdsButton()
        
        XCTAssertTrue(sut.showAdsFreeView)
    }
    
    @MainActor func testDidTapCloseAdsButton_shouldSaveLastTappedDate() {
        let currentTestDate = Date()
        let sut = makeSUT(expectedCloseAdsButtonTappedDate: currentTestDate)
        
        sut.didTapCloseAdsButton()
        
        XCTAssertEqual(sut.lastCloseAdsDate, currentTestDate, "Expected close ads button last tapped date should be the current date")
    }
    
    @MainActor func testDidTapCloseAdsButton_shouldTrackButtonTapEvent() {
        let mockTracker = MockTracker()
        let sut = makeSUT(tracker: mockTracker)
        
        sut.didTapCloseAdsButton()
        
        assertTrackAnalyticsEventCalled(
            trackedEventIdentifiers: mockTracker.trackedEventIdentifiers,
            with: [AdsBannerCloseAdsButtonPressedEvent()]
        )
    }
    
    // MARK: Helper
    @MainActor private func makeSUT(
        adsSlotUpdatesProvider: any AdsSlotUpdatesProviderProtocol = MockAdsSlotUpdatesProvider(),
        adsList: [String: String] = [:],
        isExternalAdsFlagEnabled: Bool = true,
        adMobConsentManager: GoogleMobileAdsConsentManagerProtocol = MockGoogleMobileAdsConsentManager(),
        appEnvironmentUseCase: some AppEnvironmentUseCaseProtocol = MockAppEnvironmentUseCase(),
        isNewAccount: Bool = false,
        accountDetailsResult: Result<AccountDetailsEntity, AccountDetailsErrorEntity> = .success(AccountDetailsEntity.build(proLevel: .free)),
        expectedCloseAdsButtonTappedDate: Date = Date(),
        tracker: some AnalyticsTracking = MockTracker(),
        isLoggedIn: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> AdsSlotViewModel {
        let sut = AdsSlotViewModel(
            adsSlotUpdatesProvider: adsSlotUpdatesProvider,
            remoteFeatureFlagUseCase: MockRemoteFeatureFlagUseCase(list: [.externalAds: isExternalAdsFlagEnabled]),
            adMobConsentManager: adMobConsentManager,
            appEnvironmentUseCase: appEnvironmentUseCase,
            accountUseCase: MockAccountUseCase(isLoggedIn: isLoggedIn, accountDetailsResult: accountDetailsResult),
            purchaseUseCase: MockAccountPlanPurchaseUseCase(),
            preferenceUseCase: MockPreferenceUseCase(),
            tracker: tracker,
            adsFreeViewProPlanAction: {},
            currentDate: { expectedCloseAdsButtonTappedDate },
            notificationCenter: notificationCenter
        )
        trackForMemoryLeaks(on: sut, file: file, line: line)
        return sut
    }
    
    private func makeAdsSlotUpdatesStream(adsSlotConfigs: [AdsSlotConfig?]) -> AnyAsyncSequence<AdsSlotConfig?> {
        AsyncStream { continuation in
            adsSlotConfigs.forEach {
                continuation.yield($0)
            }
            continuation.finish()
        }.eraseToAnyAsyncSequence()
    }

    private var randomAdsSlotConfig: AdsSlotConfig {
        let adsSlot: AdsSlotEntity = [.files, .home, .photos, .sharedLink].randomElement() ?? .files
        return AdsSlotConfig(adsSlot: adsSlot, displayAds: Bool.random())
    }
}
