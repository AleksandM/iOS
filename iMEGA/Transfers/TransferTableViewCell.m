#import "TransferTableViewCell.h"

#import "Helper.h"
#import "MEGAPauseTransferRequestDelegate.h"
#import "MEGAGetThumbnailRequestDelegate.h"
#import "MEGASdkManager.h"
#import "UIImageView+MNZCategory.h"
#import <Photos/Photos.h>
#import "MEGAStore.h"
#import "MEGAProcessAsset.h"
#import "NSString+MNZCategory.h"
#import "NSFileManager+MNZCategory.h"
#import "SVProgressHUD.h"

@interface TransferTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (assign, nonatomic) BOOL isPaused;
@property (strong, nonatomic) MEGATransfer *transfer;
@property (strong, nonatomic) PHAsset *asset;

@end

@implementation TransferTableViewCell

#pragma mark - Public

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = UIColor.clearColor;
        view.userInteractionEnabled = NO;
        self.selectedBackgroundView = view;
        
        self.lineView.backgroundColor = UIColor.mnz_grayCCCCCC;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = UIColor.clearColor;
        self.selectedBackgroundView = view;
        
        self.lineView.backgroundColor = UIColor.mnz_grayCCCCCC;
    }
}

- (void)configureCellForTransfer:(MEGATransfer *)transfer delegate:(id<TransferTableViewCellDelegate>)delegate {
    self.delegate = delegate;
    self.transfer = transfer;
    
    self.nameLabel.text = [[MEGASdkManager sharedMEGASdk] unescapeFsIncompatible:self.transfer.fileName];
    
    MEGANode *node = [[MEGASdkManager sharedMEGASdk] nodeForHandle:self.transfer.nodeHandle];
    switch (self.transfer.type) {
        case MEGATransferTypeDownload: {
            if (node.hasThumbnail) {
                NSString *thumbnailFilePath = [Helper pathForNode:node inSharedSandboxCacheDirectory:@"thumbnailsV3"];
                if ([[NSFileManager defaultManager] fileExistsAtPath:thumbnailFilePath]) {
                    self.iconImageView.image = [UIImage imageWithContentsOfFile:thumbnailFilePath];
                } else {
                    MEGAGetThumbnailRequestDelegate *getThumbnailRequestDelegate = [[MEGAGetThumbnailRequestDelegate alloc] initWithCompletion:^(MEGARequest *request) {
                        self.iconImageView.image = [UIImage imageWithContentsOfFile:request.file];
                    }];
                    [[MEGASdkManager sharedMEGASdk] getThumbnailNode:node destinationFilePath:thumbnailFilePath delegate:getThumbnailRequestDelegate];
                    [self.iconImageView mnz_imageForNode:node];
                }
            } else {
                if (transfer.type == MEGATransferTypeDownload) {
                    [self.iconImageView mnz_imageForNode:node];
                } else {
                    [self.iconImageView mnz_setImageForExtension:transfer.fileName.pathExtension];
                }
            }
            break;
        }
            
        case MEGATransferTypeUpload: {
            NSString *transferAbsolutePath = [[NSHomeDirectory() stringByAppendingPathComponent:transfer.path] stringByAppendingString:@"_thumbnail"];
            self.iconImageView.image = [UIImage imageWithContentsOfFile:transferAbsolutePath];
            break;
        }
            
        default:
            break;
    }
    
    
    [self configureCellState];
}

- (void)configureCellForAsset:(PHAsset *)asset delegate:(id<TransferTableViewCellDelegate>)delegate {
    self.delegate = delegate;
    self.asset = asset;
    
    PHAssetResource *assetResource = [PHAssetResource assetResourcesForAsset:self.asset].firstObject;
    self.nameLabel.text = assetResource.originalFilename;

    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:self.iconImageView.frame.size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            self.iconImageView.image = result;
        } else {
            [self.iconImageView mnz_setImageForExtension:assetResource.originalFilename.pathExtension];
        }
    }];
    
    [self queuedStateLayout];
}

- (void)updatePercentAndSpeedLabelsForTransfer:(MEGATransfer *)transfer {
    self.transfer = transfer;
    
    if (transfer.type == MEGATransferTypeDownload) {
        self.arrowImageView.image = [Helper downloadingTransferImage];
        self.percentageLabel.textColor = UIColor.mnz_green31B500;
    } else {
        self.arrowImageView.image = [Helper uploadingTransferImage];
        self.percentageLabel.textColor = UIColor.mnz_blue2BA6DE;
    }
    
    float percentage = (transfer.transferredBytes.floatValue / transfer.totalBytes.floatValue * 100);
    NSString *percentageCompleted = [NSString stringWithFormat:@"%.f %%", percentage];
    self.percentageLabel.text = percentageCompleted;
    NSString *speed = [NSString stringWithFormat:@"%@/s", [NSByteCountFormatter stringFromByteCount:transfer.speed.longLongValue countStyle:NSByteCountFormatterCountStyleMemory]];
    self.speedLabel.text = speed;
}

#pragma mark - Private

- (void)configureCellState {

    switch (self.transfer.state) {
            
        case MEGATransferStateActive:
            [self.pauseButton setImage:[UIImage imageNamed:@"pauseTransfers"] forState:UIControlStateNormal];
            [self updatePercentAndSpeedLabelsForTransfer:self.transfer];
            break;
            
        case MEGATransferStatePaused:
            [self inactiveStateLayout];
            self.percentageLabel.text = AMLocalizedString(@"paused", @"Paused");
            [self.pauseButton setImage:[UIImage imageNamed:@"resumeTransfers"] forState:UIControlStateNormal];
            break;
            
        case MEGATransferStateRetrying:
            [self inactiveStateLayout];
            self.percentageLabel.text = AMLocalizedString(@"Retrying...", @"Label for the state of a transfer when is being retrying - (String as short as possible).");
            break;
            
        case MEGATransferStateCompleting:
            [self inactiveStateLayout];
            self.percentageLabel.text = AMLocalizedString(@"Completing...", @"Label for the state of a transfer when is being completing - (String as short as possible).");
            break;
            
        default:
            [self inactiveStateLayout];
            self.percentageLabel.text = AMLocalizedString(@"queued", @"Queued");
            break;
    }
}

- (void)inactiveStateLayout {
    [self.pauseButton setImage:[UIImage imageNamed:@"pauseTransfers"] forState:UIControlStateNormal];
    self.percentageLabel.textColor = UIColor.mnz_gray666666;
    
    if (self.transfer.type == MEGATransferTypeDownload) {
        self.arrowImageView.image = [Helper downloadQueuedTransferImage];
    } else {
        self.arrowImageView.image = [Helper uploadQueuedTransferImage];
    }
}

- (void)queuedStateLayout {
    self.percentageLabel.textColor = UIColor.mnz_gray666666;
    self.arrowImageView.image = [Helper uploadQueuedTransferImage];
    self.percentageLabel.text = AMLocalizedString(@"queued", @"Queued");
}

#pragma mark - IBActions

- (IBAction)cancelTransfer:(id)sender {
    if (self.transfer) {
        if ([[MEGASdkManager sharedMEGASdk] transferByTag:self.transfer.tag] != nil) {
            [[MEGASdkManager sharedMEGASdk] cancelTransferByTag:self.transfer.tag];
        } else {
            if ([[MEGASdkManager sharedMEGASdkFolder] transferByTag:self.transfer.tag] != nil) {
                [[MEGASdkManager sharedMEGASdkFolder] cancelTransferByTag:self.transfer.tag];
            }
        }
    } else if (self.asset) {
        [[MEGAStore shareInstance] deleteUploadTransferWithLocalIdentifier:self.asset.localIdentifier];
    }
}

- (IBAction)pauseTransfer:(id)sender {
    if (self.transfer) {
        self.isPaused = self.transfer.state == MEGATransferStatePaused;
        
        MEGAPauseTransferRequestDelegate *pauseTransferDelegate = [[MEGAPauseTransferRequestDelegate alloc] initWithCompletion:^(MEGARequest *request) {
            self.isPaused = self.transfer.state == MEGATransferStatePaused;
            [self.delegate pauseTransferCell:self];
        }];
        
        if ([[MEGASdkManager sharedMEGASdk] transferByTag:self.transfer.tag] != nil) {
            [[MEGASdkManager sharedMEGASdk] pauseTransferByTag:self.transfer.tag pause:!self.isPaused delegate:pauseTransferDelegate];
        } else {
            if ([[MEGASdkManager sharedMEGASdkFolder] transferByTag:self.transfer.tag] != nil) {
                [[MEGASdkManager sharedMEGASdkFolder] pauseTransferByTag:self.transfer.tag pause:!self.isPaused delegate:pauseTransferDelegate];
            }
        }
    } else if (self.asset) {
        
        MOUploadTransfer *uploadTransfer = [[MEGAStore shareInstance] fetchTransferUpdateWithLocalIdentifier:self.asset.localIdentifier];
        
        MEGANode *parentNode = [[MEGASdkManager sharedMEGASdk] nodeForHandle:uploadTransfer.parentNodeHandle.unsignedLongLongValue];
        MEGAProcessAsset *processAsset = [[MEGAProcessAsset alloc] initWithAsset:self.asset parentNode:parentNode filePath:^(NSString *filePath) {
            NSString *name = filePath.lastPathComponent;
            NSString *newName = [self sequenceNameForNodeNamed:name parentNode:parentNode];
            
            NSString *appData = [NSString new];
            
            appData = [appData mnz_appDataToSaveCoordinates:[filePath mnz_coordinatesOfPhotoOrVideo]];
            
            if (![name isEqualToString:newName]) {
                NSString *newFilePath = [[NSFileManager defaultManager].uploadsDirectory stringByAppendingPathComponent:newName];
                
                NSError *error = nil;
                NSString *absoluteFilePath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
                if (![[NSFileManager defaultManager] moveItemAtPath:absoluteFilePath toPath:newFilePath error:&error]) {
                    MEGALogError(@"Move item at path failed with error: %@", error);
                }
                [[MEGASdkManager sharedMEGASdk] startUploadWithLocalPath:[newFilePath stringByReplacingOccurrencesOfString:[NSHomeDirectory() stringByAppendingString:@"/"] withString:@""] parent:parentNode appData:appData isSourceTemporary:YES];
            } else {
                [[MEGASdkManager sharedMEGASdk] startUploadWithLocalPath:[filePath stringByReplacingOccurrencesOfString:[NSHomeDirectory() stringByAppendingString:@"/"] withString:@""] parent:parentNode appData:appData isSourceTemporary:YES];
            }
        } node:^(MEGANode *node) {
            if ([[[MEGASdkManager sharedMEGASdk] parentNodeForNode:node] handle] == parentNode.handle) {
                MEGALogDebug(@"The asset exists in MEGA in the parent folder");
            } else {
                [[MEGASdkManager sharedMEGASdk] copyNode:node newParent:parentNode];
            }
        } error:^(NSError *error) {
            [SVProgressHUD showImage:[UIImage imageNamed:@"hudError"] status:[NSString stringWithFormat:@"%@ %@", AMLocalizedString(@"Transfer failed:", nil), self.nameLabel.text]];
        }];
        [processAsset prepare];
        
        [[MEGAStore shareInstance] deleteUploadTransferWithLocalIdentifier:self.asset.localIdentifier];
    }
}

#pragma mark - Private

- (NSString *)sequenceNameForNodeNamed:(NSString *)name parentNode:(MEGANode *)parentNode {
    NSString *nameWithoutExtension = [name stringByDeletingPathExtension];
    NSString *extension = [name pathExtension];
    int index = 0;
    int listSize = 0;
    
    do {
        if (index != 0) {
            nameWithoutExtension = [[name stringByDeletingPathExtension] stringByAppendingString:[NSString stringWithFormat:@"_%d", index]];
        }
        
        MEGANodeList *nameNodeList = [[MEGASdkManager sharedMEGASdk] nodeListSearchForNode:parentNode searchString:[nameWithoutExtension stringByAppendingPathExtension:extension]];
        listSize = [nameNodeList.size intValue];
        index++;
    } while (listSize != 0);
    
    return [nameWithoutExtension stringByAppendingPathExtension:extension];
}

@end
