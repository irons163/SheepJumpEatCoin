//
//  StarNode.m
//  UberJump
//

#import "StarNode.h"
#import "GameState.h"

@import AVFoundation;

@interface StarNode ()
{
	SKAction *_starSound;
}
@end


@implementation StarNode

- (id) init
{
	if (self = [super init]) {
		// Sound for when we collect a Star
		_starSound = [SKAction playSoundFileNamed:@"StarPing.wav" waitForCompletion:NO];
	}
	
	return self;
}

- (BOOL) collisionWithPlayer:(SKNode *)player
{
	// Boost the player up
	player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 400.0f);
	
	// Play sound
	[self.parent runAction:_starSound];
	
	// Remove this Star
	[self removeFromParent];
	
	// Award score
	[GameState sharedInstance].score += (_starType == STAR_NORMAL ? 20 : 100);
	
	// Award stars
	[GameState sharedInstance].stars += (_starType == STAR_NORMAL ? 1 : 5);
	
	// The HUD needs updating to show the new stars and score
	return YES;
	
}

@end
