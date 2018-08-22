//
//  GameObjectNode.m
//  UberJump
//

#import "GameObjectNode.h"

@implementation GameObjectNode

- (BOOL) collisionWithPlayer:(SKNode *)player
{
	return NO;
}

- (void) checkNodeRemoval:(CGFloat)playerY
{
	if (playerY > self.position.y + 300.0f) {
		[self removeFromParent];
	}
}

@end
