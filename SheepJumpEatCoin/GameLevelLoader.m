//
//  GameLevelLoader.m
//  SheepJumpEatCoin
//
//  Created by irons on 2021/11/23.
//  Copyright © 2021 irons. All rights reserved.
//

#import "GameLevelLoader.h"

@implementation GameLevelLoader

- (void)load {
    // Load the level
    NSString *levelPlist = [[NSBundle mainBundle] pathForResource: @"Level02" ofType: @"plist"];
    NSDictionary *levelData = [NSDictionary dictionaryWithContentsOfFile:levelPlist];
    
    // Height at which the player ends the level
    _endY = [levelData[@"EndY"] integerValue];
    
    // Add the platforms
    NSDictionary *platforms = levelData[@"Platforms"];
    NSDictionary *platformPatterns = platforms[@"Patterns"];
    NSArray *platformPositions = platforms[@"Positions"];
    for (NSDictionary *platformPosition in platformPositions) {
        CGFloat patternX = [platformPosition[@"x"] floatValue];
        CGFloat patternY = [platformPosition[@"y"] floatValue];
        NSString *pattern = platformPosition[@"pattern"];
        
        // Look up the pattern
        NSArray *platformPattern = platformPatterns[pattern];
        for (NSDictionary *platformPoint in platformPattern) {
            CGFloat x = [platformPoint[@"x"] floatValue];
            CGFloat y = [platformPoint[@"y"] floatValue];
            NSInteger type = [platformPoint[@"type"] integerValue];
            
//            PlatformNode *platformNode = [self createPlatformAtPosition:CGPointMake(x + patternX, y + patternY) ofType:type];
            if (_platformInfoBlock) {
                _platformInfoBlock(CGPointMake(x + patternX, y + patternY), type);
            }
        }
    }
    
    // Add the stars
    NSDictionary *stars = levelData[@"Stars"];
    NSDictionary *starPatterns = stars[@"Patterns"];
    NSArray *starPositions = stars[@"Positions"];
    for (NSDictionary *starPosition in starPositions) {
        CGFloat patternX = [starPosition[@"x"] floatValue];
        CGFloat patternY = [starPosition[@"y"] floatValue];
        NSString *pattern = starPosition[@"pattern"];
        
        // Look up the pattern
        NSArray *starPattern = starPatterns[pattern];
        for (NSDictionary *starPoint in starPattern) {
            CGFloat x = [starPoint[@"x"] floatValue];
            CGFloat y = [starPoint[@"y"] floatValue];
            NSInteger type = [starPoint[@"type"] intValue];
            
//            StarNode *starNode = [self createStarAtPosition:CGPointMake(x + patternX, y + patternY) ofType:type];
//            [_foregroundNode addChild:starNode];
            if (_starInfoBlock) {
                _starInfoBlock(CGPointMake(x + patternX, y + patternY), type);
            }
        }
    }
}

@end
