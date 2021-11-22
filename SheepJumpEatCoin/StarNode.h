//
//  StarNode.h
//  UberJump
//

#import "GameObjectNode.h"

typedef NS_ENUM(int, StarType) {
	STAR_NORMAL,
	STAR_SPECIAL,
};

@interface StarNode : GameObjectNode

+ (instancetype)node NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (id)initWithType:(StarType)type;

@property (readonly, assign) StarType type;
@property (nonatomic, assign) uint32_t categoryBitMask;
@property (nonatomic, assign) uint32_t contactTestBitMask;

@end
