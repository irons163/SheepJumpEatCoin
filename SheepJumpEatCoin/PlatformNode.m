//
//  PlatformNode.m
//  UberJump
//

#import "PlatformNode.h"

@implementation PlatformNode

- (id)initWithType:(PlatformType)type {
    if (self = [super init]) {
        _type = type;
        [self setup];
    }
    
    return self;
}

- (void)setup {    
    SKSpriteNode *sprite;
    if (_type == PLATFORM_BREAK) {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"PlatformBreak"];
    } else {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Platform"];
    }
    [self addChild:sprite];
    
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
    self.physicsBody.dynamic = NO;
    self.physicsBody.collisionBitMask = 0;
}

- (BOOL)collisionWithPlayer:(SKNode *)player {
    // Only bounce the player if he's falling
    if (player.physicsBody.velocity.dy < 0) {
        player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 250.0f);
        
        // Remove if it is a Break type platform
        if (_type == PLATFORM_BREAK) {
            [self removeFromParent];
        }
    }
    
    return NO;
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
