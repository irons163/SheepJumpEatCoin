//
//  Player.h
//  SheepJumpEatCoin
//
//  Created by irons on 2021/11/22.
//  Copyright © 2021 irons. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Player : SKNode

@property NSInteger maxPlayerY; // Max y reached by player
@property NSInteger goalLineY; // Height at which level ends
@property (nonatomic, assign) uint32_t categoryBitMask;
@property (nonatomic, assign) uint32_t contactTestBitMask;

- (void)updateStatus;
- (void)updateVelocityXwithXAcceleration:(CGFloat)xAcceleration;
- (void)startjumping;
- (BOOL)arrivedGoalLine;
- (BOOL)lostLife;

@end

NS_ASSUME_NONNULL_END
