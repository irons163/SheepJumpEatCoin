//
//  Player.m
//  SheepJumpEatCoin
//
//  Created by irons on 2021/11/22.
//  Copyright © 2021 irons. All rights reserved.
//

#import "Player.h"

@interface Player()

@property (readonly) BOOL isJumping;

@end

@implementation Player

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _maxPlayerY = 80;
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"sheep_jump2"];
    sprite.size = CGSizeMake(50, 50);
    [self addChild:sprite];
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width / 2];
    self.physicsBody.dynamic = NO;
    self.physicsBody.allowsRotation = NO;
    self.physicsBody.restitution = 1.0f;
    self.physicsBody.friction = 0.0f;
    self.physicsBody.angularDamping = 0.0f;
    self.physicsBody.linearDamping = 0.0f;
    
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.physicsBody.collisionBitMask = 0;
}

- (void)updateStatus {
    if ((int)self.position.y > self.maxPlayerY) {
        self.maxPlayerY = (int)self.position.y;
    }
    
    if (self.physicsBody.velocity.dy < 0) {
        if (_isJumping) {
            _isJumping = false;
            ((SKSpriteNode *)self.children.firstObject).texture = [SKTexture textureWithImageNamed:@"sheep_jump3"];
        }
    } else {
        if (!_isJumping) {
            _isJumping = true;
            ((SKSpriteNode *)self.children.firstObject).texture = [SKTexture textureWithImageNamed:@"sheep_jump1"];
        }
    }
}

- (void)updateVelocityXwithXAcceleration:(CGFloat)xAcceleration {
    self.physicsBody.velocity = CGVectorMake(xAcceleration * 400.0f, self.physicsBody.velocity.dy);
}

- (void)startjumping {
    self.physicsBody.dynamic = YES;
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
