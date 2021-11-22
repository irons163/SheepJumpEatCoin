//
//  PlatformNode.h
//  UberJump
//

#import "GameObjectNode.h"

typedef NS_ENUM(int, PlatformType) {
	PLATFORM_NORMAL,
	PLATFORM_BREAK,
};

@interface PlatformNode : GameObjectNode

+ (instancetype)node NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (id)initWithType:(PlatformType)type;

@property (nonatomic, assign) PlatformType type;
@property (nonatomic, assign) uint32_t categoryBitMask;
@property (nonatomic, assign) uint32_t contactTestBitMask;

@end
