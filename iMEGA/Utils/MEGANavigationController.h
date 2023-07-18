#import <UIKit/UIKit.h>

@protocol MEGANavigationControllerDelegate <NSObject>
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated;
@optional
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated;
@end


@interface MEGANavigationController : UINavigationController <UIGestureRecognizerDelegate, UINavigationControllerDelegate>

- (void)addRightCancelButton;
- (void)addLeftDismissButtonWithText:(NSString *)text;
- (void)addLeftDismissBarButton:(UIBarButtonItem *)barButton;

@property (weak, nonatomic) id<MEGANavigationControllerDelegate> navigationDelegate;

@end
