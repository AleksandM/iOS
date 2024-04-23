#import <UIKit/UIKit.h>
#import "MEGACallManager.h"
#import "MEGAProviderDelegate.h"
#import <PushKit/PushKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MEGANotificationType) {
    MEGANotificationTypeShareFolder = 1,
    MEGANotificationTypeChatMessage = 2,
    MEGANotificationTypeContactRequest = 3
};

@class MainTabBarController;
@class CloudDriveQuickUploadActionRouter;

@interface AppDelegate : UIResponder <PKPushRegistryDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, nullable) MEGACallManager *megaCallManager;
@property (nonatomic, nullable) MEGAProviderDelegate *megaProviderDelegate;
@property (strong, nonatomic, nullable) UIWindow *blockingWindow;
@property (nonatomic, weak, readonly) MainTabBarController *mainTBC;
@property (nonatomic) NSNumber *openChatLater;
@property (nonatomic) BOOL showAccountUpgradeScreen;
@property (nonatomic) BOOL loadProductsAndShowAccountUpgradeScreen;
@property (strong, nonatomic) CloudDriveQuickUploadActionRouter* quickUploadActionRouter;

- (void)showMainTabBar;
- (void)performCall;
- (void)showOnboardingWithCompletion:(nullable void (^)(void))completion;
- (void)presentAccountExpiredAlertIfNeeded;
- (void)showLink:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
