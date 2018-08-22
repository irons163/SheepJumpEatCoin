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

@property (nonatomic, assign) StarType starType;

@end
