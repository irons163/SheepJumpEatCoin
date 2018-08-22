//
//  PlatformNode.m
//  UberJump
//

#import "PlatformNode.h"

@implementation PlatformNode

- (BOOL) collisionWithPlayer:(SKNode *)player
{
	// 1
	// Only bounce the player if he's falling
	if (player.physicsBody.velocity.dy < 0) {
		// 2
		player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 250.0f);
		
		// 3
		// Remove if it is a Break type platform
		if (_platformType == PLATFORM_BREAK) {
			[self removeFromParent];
		}
	}
	
	// 4
	// No stars for platforms
	return NO;
}

@end
