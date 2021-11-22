//
//  GameLevelLoader.h
//  SheepJumpEatCoin
//
//  Created by irons on 2021/11/23.
//  Copyright © 2021 irons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GameLevelLoader : NSObject

@property NSInteger endY;
@property (copy) void(^platformInfoBlock)(CGPoint position, NSInteger type);
@property (copy) void(^starInfoBlock)(CGPoint position, NSInteger type);

- (void)load;

@end

NS_ASSUME_NONNULL_END
