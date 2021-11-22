//
//  Player.m
//  SheepJumpEatCoin
//
//  Created by irons on 2021/11/22.
//  Copyright © 2021 irons. All rights reserved.
//

#import "Player.h"

@implementation Player

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _maxPlayerY = 80;
    
//    SKNode *playerNode = [SKNode node];
    [self setPosition:CGPointMake(160.0f, 80.0f)];
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"sheep_jump2"];
    sprite.size = CGSizeMake(50, 50);
    [self addChild:sprite];
    
    // 1
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
    // 2
    self.physicsBody.dynamic = NO;
    // 3
    self.physicsBody.allowsRotation = NO;
    // 4
    self.physicsBody.restitution = 1.0f;
    self.physicsBody.friction = 0.0f;
    self.physicsBody.angularDamping = 0.0f;
    self.physicsBody.linearDamping = 0.0f;
    
    // 1
    self.physicsBody.usesPreciseCollisionDetection = YES;
    // 2
//    self.physicsBody.categoryBitMask = CollisionCategoryPlayer;
    // 3
    self.physicsBody.collisionBitMask = 0;
    // 4
//    playerNode.physicsBody.contactTestBitMask = CollisionCategoryStar | CollisionCategoryPlatform;
    
//    return self;
}

- (void)updateStatus {
    // New max height ?
    if ((int)self.position.y > self.maxPlayerY) {
        self.maxPlayerY = (int)self.position.y;
    }
    
    if (self.position.y < (_maxPlayerY)) {
        if (!_isDroping) {
            _isDroping = true;
            ((SKSpriteNode *)self.children.firstObject).texture = [SKTexture textureWithImageNamed:@"sheep_jump3"];
        }
    } else {
        if (_isDroping) {
            _isDroping = false;
            ((SKSpriteNode *)self.children.firstObject).texture = [SKTexture textureWithImageNamed:@"sheep_jump1"];
        }
    }
}

- (void)updateVelocityXwithXAcceleration:(CGFloat)xAcceleration {
    self.physicsBody.velocity = CGVectorMake(xAcceleration * 400.0f, self.physicsBody.velocity.dy);
}

- (void)startjumping {
    // 3
    // Start the player by putting them into the physics simulation
    self.physicsBody.dynamic = YES;
    // 4
    [self.physicsBody applyImpulse:CGVectorMake(0.0f, 20.0f)];
}

- (BOOL)arrivedGoalLine {
    return self.position.y > _goalLineY;
}

- (BOOL)lostLife {
    return self.position.y < (self.maxPlayerY - 400);
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
