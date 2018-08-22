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

@property (nonatomic, assign) PlatformType platformType;

@end
