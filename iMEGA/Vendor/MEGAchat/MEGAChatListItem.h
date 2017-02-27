#import <Foundation/Foundation.h>
#import "MEGAChatMessage.h"

typedef NS_ENUM (NSInteger, MEGAChatListItemChangeType) {
    MEGAChatListItemChangeTypeStatus       = 0x01,
    MEGAChatListItemChangeTypeVisibility   = 0x02,
    MEGAChatListItemChangeTypeUnreadCount  = 0x04,
    MEGAChatListItemChangeTypeParticipants = 0x08,
    MEGAChatListItemChangeTypeTitle        = 0x10,
    MEGAChatListItemChangeTypeClosed       = 0x20,
    MEGAChatListItemChangeTypeLastMsg      = 0x40,
    MEGAChatListItemChangeTypeLastTs       = 0x80
};

typedef NS_ENUM (NSInteger, MEGAChatStatus);
typedef NS_ENUM (NSInteger, MEGAChatMessageType);

@interface MEGAChatListItem : NSObject

@property (readonly, nonatomic) uint64_t chatId;
@property (readonly, nonatomic) NSString *title;
@property (readonly, nonatomic) MEGAChatListItemChangeType changes;
@property (readonly, nonatomic) MEGAChatStatus onlineStatus;
@property (readonly, nonatomic) NSInteger visibility;
@property (readonly, nonatomic) NSInteger unreadCount;
@property (readonly, nonatomic, getter=isGroup) BOOL group;
@property (readonly, nonatomic) uint64_t peerHandle;
@property (readonly, nonatomic, getter=isActive) BOOL active;

@property (readonly, nonatomic) NSString *lastMessage;
@property (readonly, nonatomic) MEGAChatMessageType lastMessageType;
@property (readonly, nonatomic) uint64_t lastMessageSender;
@property (readonly, nonatomic) NSDate *lastMessageDate;

- (instancetype)clone;

- (BOOL)hasChangedForType:(MEGAChatListItemChangeType)changeType;

+ (NSString *)stringForChangeType:(MEGAChatListItemChangeType)changeType;
+ (NSString *)stringForStatus:(MEGAChatStatus)status;
+ (NSString *)stringForVisibility:(NSInteger)visibility;

@end
