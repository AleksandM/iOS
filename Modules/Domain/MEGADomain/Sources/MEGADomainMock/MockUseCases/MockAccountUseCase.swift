import Foundation
import MEGADomain

public class MockAccountUseCase: AccountUseCaseProtocol, @unchecked Sendable {
    private let totalNodesCountVariable: UInt64
    private let getMyChatFilesFolderResult: (Result<NodeEntity, AccountErrorEntity>)
    private let accountDetailsResult: (Result<AccountDetailsEntity, AccountDetailsErrorEntity>)
    private let miscFlagsResult: Result<Void, AccountErrorEntity>
    private let sessionTransferURLResult: Result<URL, AccountErrorEntity>
    private let isUpgradeSecuritySuccess: Bool
    private let multiFactorAuthCheckResult: Bool
    private var multiFactorAuthCheckDelay: TimeInterval
    private let _bandwidthOverquotaDelay: Int64
    private let _currentUser: UserEntity?
    private let _isGuest: Bool
    private let _isNewAccount: Bool
    private let _accountCreationDate: Date?
    private let _isLoggedIn: Bool
    private let _hasValidProAccount: Bool
    private let _isBilledProPlan: Bool
    private let _hasMultipleBilledProPlan: Bool
    private let _currentProPlan: AccountPlanEntity?
    private let _currentSubscription: AccountSubscriptionEntity?
    private let _isStandardProAccount: Bool
    private let _contacts: [UserEntity]
    private var _currentAccountDetails: AccountDetailsEntity?
    private let _isOverQuota: Bool
    private let _email: String?
    private let _isMasterBusinessAccount: Bool
    private let _isAchievementsEnabled: Bool
    private let smsState: SMSStateEntity
    private let _hasValidProOrUnexpiredBusinessAccount: Bool
    private let _rootStorage: Int64
    private let _rubbishBinStorage: Int64
    private let _incomingSharesStorage: Int64
    private let _backupStorage: Int64
    private let _currentAccountPlan: PlanEntity?
    private var _hasValidSubscription: Bool
    private let _hasActiveBusinessAccount: Bool
    private let _hasActiveProFlexiAccount: Bool

    public init(
        currentUser: UserEntity? = UserEntity(handle: .invalid),
        isGuest: Bool = false,
        isNewAccount: Bool = false,
        isLoggedIn: Bool = true,
        hasValidProAccount: Bool = false,
        isBilledProPlan: Bool = false,
        hasMultipleBilledProPlan: Bool = false,
        isStandardProAccount: Bool = false,
        accountCreationDate: Date? = nil,
        contacts: [UserEntity] = [],
        totalNodesCountVariable: UInt64 = 0,
        getMyChatFilesFolderResult: Result<NodeEntity, AccountErrorEntity> = .failure(.nodeNotFound),
        currentAccountDetails: AccountDetailsEntity? = nil,
        accountDetailsResult: Result<AccountDetailsEntity, AccountDetailsErrorEntity> = .failure(.generic),
        miscFlagsResult: Result<Void, AccountErrorEntity> = .failure(.generic),
        sessionTransferURLResult: Result<URL, AccountErrorEntity> = .failure(.generic),
        isUpgradeSecuritySuccess: Bool = false,
        bandwidthOverquotaDelay: Int64 = 0,
        isOverQuota: Bool = false,
        email: String? = nil,
        isMasterBusinessAccount: Bool = false,
        isAchievementsEnabled: Bool = false,
        smsState: SMSStateEntity = .notAllowed,
        multiFactorAuthCheckResult: Bool = false,
        multiFactorAuthCheckDelay: TimeInterval = 0,
        hasValidProOrUnexpiredBusinessAccount: Bool = false,
        rootStorage: Int64 = 0,
        rubbishBinStorage: Int64 = 0,
        incomingSharesStorage: Int64 = 0,
        backupStorage: Int64 = 0,
        accountPlan: PlanEntity? = nil,
        currentProPlan: AccountPlanEntity? = nil,
        currentSubscription: AccountSubscriptionEntity? = nil,
        hasValidSubscription: Bool = false,
        hasActiveBusinessAccount: Bool = false,
        hasActiveProFlexiAccount: Bool = false
    ) {
        _currentUser = currentUser
        _isGuest = isGuest
        _isNewAccount = isNewAccount
        _isLoggedIn = isLoggedIn
        _hasValidProAccount = hasValidProAccount
        _isStandardProAccount = isStandardProAccount
        _isBilledProPlan = isBilledProPlan
        _hasMultipleBilledProPlan = hasMultipleBilledProPlan
        _currentProPlan = currentProPlan
        _currentSubscription = currentSubscription
        _accountCreationDate = accountCreationDate
        _contacts = contacts
        _currentAccountDetails = currentAccountDetails
        _bandwidthOverquotaDelay = bandwidthOverquotaDelay
        _isOverQuota = isOverQuota
        _email = email
        _isMasterBusinessAccount = isMasterBusinessAccount
        _isAchievementsEnabled = isAchievementsEnabled
        self.smsState = smsState
        self.totalNodesCountVariable = totalNodesCountVariable
        self.getMyChatFilesFolderResult = getMyChatFilesFolderResult
        self.accountDetailsResult = accountDetailsResult
        self.miscFlagsResult = miscFlagsResult
        self.sessionTransferURLResult = sessionTransferURLResult
        self.isUpgradeSecuritySuccess = isUpgradeSecuritySuccess
        self.multiFactorAuthCheckResult = multiFactorAuthCheckResult
        self.multiFactorAuthCheckDelay = multiFactorAuthCheckDelay
        _hasValidProOrUnexpiredBusinessAccount = hasValidProOrUnexpiredBusinessAccount
        _rootStorage = rootStorage
        _rubbishBinStorage = rubbishBinStorage
        _incomingSharesStorage = incomingSharesStorage
        _backupStorage = backupStorage
        _currentAccountPlan = accountPlan
        _hasValidSubscription = hasValidSubscription
        _hasActiveBusinessAccount = hasActiveBusinessAccount
        _hasActiveProFlexiAccount = hasActiveProFlexiAccount
    }
    
    // MARK: - User authentication status and identifiers
    public var currentUserHandle: HandleEntity? {
        _currentUser?.handle
    }
    
    public var isGuest: Bool {
        _isGuest
    }
    
    public var isNewAccount: Bool {
        _isNewAccount
    }
    
    public var myEmail: String? {
        _email
    }
    
    // MARK: - Account characteristics
    public var accountCreationDate: Date? {
        _accountCreationDate
    }
    
    public var currentAccountDetails: AccountDetailsEntity? {
        _currentAccountDetails
    }
    
    public var bandwidthOverquotaDelay: Int64 {
        _bandwidthOverquotaDelay
    }
    
    public var isOverQuota: Bool {
        _isOverQuota
    }
    
    public var isMasterBusinessAccount: Bool {
        _isMasterBusinessAccount
    }
    
    public var isAchievementsEnabled: Bool {
        _isAchievementsEnabled
    }

    public var hasValidSubscription: Bool {
        _hasValidSubscription
    }

    public func currentAccountPlan() async -> PlanEntity? {
        _currentAccountPlan
    }
    
    public var isSmsAllowed: Bool {
        smsState == .optInAndUnblock
    }
    
    // MARK: - User and session management
    public func currentUser() async -> UserEntity? {
        _currentUser
    }
    
    public func isLoggedIn() -> Bool {
        _isLoggedIn
    }
    
    public func isAccountType(_ type: AccountTypeEntity) -> Bool {
        _currentAccountDetails?.proLevel == type
    }
    
    public func hasValidProAccount() -> Bool {
        _hasValidProAccount
    }
    
    public func hasValidProOrUnexpiredBusinessAccount() -> Bool {
        _hasValidProOrUnexpiredBusinessAccount
    }
    
    public func isBilledProPlan() -> Bool {
        _isBilledProPlan
    }
    
    public var currentProPlan: AccountPlanEntity? {
        _currentProPlan
    }
    
    public func currentSubscription() -> AccountSubscriptionEntity? {
        _currentSubscription
    }
    
    public func isStandardProAccount() -> Bool {
        _isStandardProAccount
    }
    
    public func hasMultipleBilledProPlans() -> Bool {
        _hasMultipleBilledProPlan
    }
    
    public func hasActiveBusinessAccount() -> Bool {
        _hasActiveBusinessAccount
    }
    
    public func hasActiveProFlexiAccount() -> Bool {
        _hasActiveProFlexiAccount
    }
    
    // MARK: - Account operations
    public func contacts() -> [UserEntity] {
        _contacts
    }
    
    public func totalNodesCount() -> UInt64 {
        totalNodesCountVariable
    }
    
    public func getMyChatFilesFolder(completion: @escaping (Result<NodeEntity, AccountErrorEntity>) -> Void) {
        completion(getMyChatFilesFolderResult)
    }
    
    public func refreshCurrentAccountDetails() async throws -> AccountDetailsEntity {
        switch accountDetailsResult {
        case .success(let details): return details
        case .failure(let error): throw error
        }
    }
    
    public func upgradeSecurity() async throws -> Bool {
        isUpgradeSecuritySuccess
    }
    
    public func getMiscFlags() async throws {
        if case .failure(let error) = miscFlagsResult {
            throw error
        }
    }
    
    public func sessionTransferURL(path: String) async throws -> URL {
        switch sessionTransferURLResult {
        case .success(let url): return url
        case .failure(let error): throw error
        }
    }
    
    public func multiFactorAuthCheck(email: String) async throws -> Bool {
        if multiFactorAuthCheckDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(multiFactorAuthCheckDelay * 1_000_000_000))
        }
        
        return multiFactorAuthCheckResult
    }
    
    public func rootStorageUsed() -> Int64 {
        _rootStorage
    }
    
    public func rubbishBinStorageUsed() -> Int64 {
        _rubbishBinStorage
    }
    
    public func incomingSharesStorageUsed() -> Int64 {
        _incomingSharesStorage
    }
    
    public func backupStorageUsed() async throws -> Int64 {
        _backupStorage
    }
    
    public func setCurrentAccountDetails(_ details: AccountDetailsEntity?) {
        _currentAccountDetails = details
    }
}
