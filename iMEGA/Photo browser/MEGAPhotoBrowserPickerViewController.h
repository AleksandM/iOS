
#import <UIKit/UIKit.h>

@class MEGAPhotoBrowserPickerViewController;

@protocol MEGAPhotoBrowserPickerDelegate

- (void)updateCurrentIndexTo:(NSUInteger)newIndex;

@end

@interface MEGAPhotoBrowserPickerViewController : UIViewController

@property (nonatomic) NSMutableArray<MEGANode *> *mediaNodes;
@property (nonatomic) id<MEGAPhotoBrowserPickerDelegate> delegate;
@property (nonatomic) MEGASdk *api;

@end
