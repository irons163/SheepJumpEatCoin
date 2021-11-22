//
//  StarNode.m
//  UberJump
//

#import "StarNode.h"
#import "GameState.h"

@import AVFoundation;

@interface StarNode () {
    SKAction *_starSound;
}
@end


@implementation StarNode

- (id)initWithType:(StarType)type {
    if (self = [super init]) {
        _type = type;
        [self setup];
    }
    
    return self;
}

- (void)setup {
    _starSound = [SKAction playSoundFileNamed:@"StarPing.wav" waitForCompletion:NO];
    
    SKSpriteNode *sprite;
    if (_type == STAR_SPECIAL) {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"StarSpecial"];
    } else {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Star"];
    }
    [self addChild:sprite];
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
    self.physicsBody.dynamic = NO;
    self.physicsBody.collisionBitMask = 0;
}

- (BOOL)collisionWithPlayer:(SKNode *)player {
    // Boost the player up
    player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 400.0f);
    
    // Play sound
    [self.parent runAction:_starSound];
    
    // Remove this Star
    [self removeFromParent];
    
    // Award score
    [GameState sharedInstance].score += (_type == STAR_NORMAL ? 20 : 100);
    
    // Award stars
    [GameState sharedInstance].stars += (_type == STAR_NORMAL ? 1 : 5);
    
    // The HUD needs updating to show the new stars and score
    return YES;
    
}

- (uint32_t)categoryBitMask {
    return self.physicsBody.categoryBitMask;
}

- (void)setCategoryBitMask:(uint32_t)categoryBitMask {
    self.physicsBody.categoryBitMask = categoryBitMask;
}

- (uint32_t)contactTestBitMask {
    return self.physicsBody.contactTestBitMask;
}

- (void)setContactTestBitMask:(uint32_t)contactTestBitMask {
    self.physicsBody.contactTestBitMask = contactTestBitMask;
}

@end
