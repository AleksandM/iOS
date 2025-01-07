import Combine
import MEGAAnalyticsiOS
import MEGADomain
import MEGAPresentation
import MEGASDKRepo
import MEGASwift
import SwiftUI

@MainActor
final public class AdsSlotViewModel: ObservableObject {
    private let remoteFeatureFlagUseCase: any RemoteFeatureFlagUseCaseProtocol
    private let adsSlotUpdatesProvider: any AdsSlotUpdatesProviderProtocol
    private let adMobConsentManager: any GoogleMobileAdsConsentManagerProtocol
    private let appEnvironmentUseCase: any AppEnvironmentUseCaseProtocol
    private let accountUseCase: any AccountUseCaseProtocol
    public let purchaseUseCase: any AccountPlanPurchaseUseCaseProtocol
    private let tracker: any AnalyticsTracking
    
    private(set) var adsSlotConfig: AdsSlotConfig?
    private(set) var monitorAdsSlotUpdatesTask: Task<Void, Never>?
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var isExternalAdsEnabled: Bool?
    @Published var displayAds: Bool = false
    @Published var showCloseButton: Bool = false
    @Published var showAdsFreeView: Bool = false
    private(set) var onViewFirstAppeared: (() -> Void)?
    public let adsFreeViewProPlanAction: (() -> Void)?
    
    @PreferenceWrapper(key: .lastCloseAdsButtonTappedDate, defaultValue: nil)
    private(set) var lastCloseAdsDate: Date?
    private let currentDate: @Sendable () -> Date
    
    public init(
        adsSlotUpdatesProvider: some AdsSlotUpdatesProviderProtocol,
        remoteFeatureFlagUseCase: some RemoteFeatureFlagUseCaseProtocol = DIContainer.remoteFeatureFlagUseCase,
        adMobConsentManager: some GoogleMobileAdsConsentManagerProtocol = GoogleMobileAdsConsentManager.shared,
        appEnvironmentUseCase: some AppEnvironmentUseCaseProtocol = AppEnvironmentUseCase.shared,
        accountUseCase: some AccountUseCaseProtocol,
        purchaseUseCase: some AccountPlanPurchaseUseCaseProtocol,
        preferenceUseCase: some PreferenceUseCaseProtocol,
        tracker: some AnalyticsTracking = DIContainer.tracker,
        onViewFirstAppeared: (() -> Void)? = nil,
        adsFreeViewProPlanAction: (() -> Void)? = nil,
        currentDate: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.adsSlotUpdatesProvider = adsSlotUpdatesProvider
        self.remoteFeatureFlagUseCase = remoteFeatureFlagUseCase
        self.adMobConsentManager = adMobConsentManager
        self.appEnvironmentUseCase = appEnvironmentUseCase
        self.accountUseCase = accountUseCase
        self.purchaseUseCase = purchaseUseCase
        self.tracker = tracker
        self.onViewFirstAppeared = onViewFirstAppeared
        self.adsFreeViewProPlanAction = adsFreeViewProPlanAction
        self.currentDate = currentDate
        
        $lastCloseAdsDate.useCase = preferenceUseCase
    }

    // MARK: Setup
    func setupSubscriptions() {
        NotificationCenter.default
            .publisher(for: .accountDidPurchasedPlan)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self, isExternalAdsEnabled == true else { return }
                
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    isExternalAdsEnabled = false
                    showAdsFreeView = false
                    updateAdsSlot()
                }
            }
            .store(in: &subscriptions)
    }

    func initializeGoogleAds() async {
        guard isExternalAdsEnabled == true else { return }
        await adMobConsentManager.initializeGoogleMobileAdsSDK()
    }

    // MARK: Remote Feature Flag
    func setupAdsRemoteFlag() async {
        // Check for enabled external ads only if there is no logged in user or the account type is free
        if accountUseCase.isLoggedIn(),
           let accountDetails = try? await accountUseCase.refreshCurrentAccountDetails(),
           accountDetails.proLevel != .free {
            isExternalAdsEnabled = false
            return
        }
        isExternalAdsEnabled = remoteFeatureFlagUseCase.isFeatureFlagEnabled(for: .externalAds)
    }
    
    // MARK: Ads Slot changes
    func startMonitoringAdsSlotUpdates() {
        monitorAdsSlotUpdatesTask?.cancel()
        monitorAdsSlotUpdatesTask = Task { [weak self, adsSlotUpdatesProvider] in
            for await newAdsSlotConfig in adsSlotUpdatesProvider.adsSlotUpdates {
                self?.updateAdsSlot(newAdsSlotConfig)
            }
        }
    }
    
    func stopMonitoringAdsSlotUpdates() {
        monitorAdsSlotUpdatesTask?.cancel()
    }
    
    func updateAdsSlot(_ newAdsSlotConfig: AdsSlotConfig? = nil) {
        if let isExternalAdsEnabled {
            guard isExternalAdsEnabled else {
                adsSlotConfig = nil
                displayAds = false
                return
            }
            
            guard adsSlotConfig != newAdsSlotConfig else {
                return
            }
        }
        
        adsSlotConfig = newAdsSlotConfig
        displayAds = newAdsSlotConfig?.displayAds ?? false
    }
    
    /// In the future, AdMob will have multiple unit ids per adSlot
    public var adMob: AdMob {
        appEnvironmentUseCase.configuration == .production ? AdMob.live : AdMob.test
    }
    
    // MARK: Close Ads button
    func bannerViewDidReceiveAd() {
        /// Show close button only when a user is logged in, otherwise, hide button
        showCloseButton = accountUseCase.isLoggedIn()
    }
    
    func didTapCloseAdsButton() {
        lastCloseAdsDate = currentDate()
        showAdsFreeView = true
        tracker.trackAnalyticsEvent(with: AdsBannerCloseAdsButtonPressedEvent())
    }
}
