//
//  GameState.h
//  UberJump
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject

@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger highScore;
@property (nonatomic, assign) NSInteger stars;

@property (assign) BOOL started;

+ (instancetype)sharedInstance;

- (void)saveState;

@end
