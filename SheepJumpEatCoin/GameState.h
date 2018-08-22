//
//  GameState.h
//  UberJump
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int highScore;
@property (nonatomic, assign) int stars;

+ (instancetype)sharedInstance;

- (void) saveState;

@end
