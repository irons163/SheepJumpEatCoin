#import "MyScene.h"
#import "StarNode.h"
#import "PlatformNode.h"
#import <CoreMotion/CoreMotion.h>
#import "EndGameScene.h"
#import "GameState.h"
#import "Player.h"

typedef NS_OPTIONS(uint32_t, CollisionCategory) {
    CollisionCategoryPlayer   = 0x1 << 0,
    CollisionCategoryStar     = 0x1 << 1,
    CollisionCategoryPlatform = 0x1 << 2,
};

@interface MyScene () <SKPhysicsContactDelegate> {
    // Layered Nodes
    SKNode *_backgroundNode;
    SKNode *_midgroundNode;
    SKNode *_foregroundNode;
    SKNode *_hudNode;
    
    // Player
    Player *_player;
    // Tap To Start node
    SKSpriteNode *_tapToStartNode;
    
    // Motion manager for accelerometer
    CMMotionManager *_motionManager;
    
    // Acceleration value from accelerometer
    CGFloat _xAcceleration;
    
    // Labels for score and stars
    SKLabelNode *_lblScore;
    SKLabelNode *_lblStars;
}

@end

@implementation MyScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // Reset
        [GameState sharedInstance].score = 0;
        [GameState sharedInstance].started = NO;
        
        // Create the game nodes
        // Background
        _backgroundNode = [self createBackgroundNode];
        [self addChild:_backgroundNode];
        
        // Midground
        _midgroundNode = [self createMidgroundNode];
        [self addChild:_midgroundNode];
        
        // Add some gravity
        self.physicsWorld.gravity = CGVectorMake(0.0f, -2.0f);
        // Set contact delegate
        self.physicsWorld.contactDelegate = self;
        
        // Foreground
        _foregroundNode = [SKNode node];
        [self addChild:_foregroundNode];
        
        // HUD
        _hudNode = [SKNode node];
        [self addChild:_hudNode];
        
        // Load the level
        NSString *levelPlist = [[NSBundle mainBundle] pathForResource: @"Level02" ofType: @"plist"];
        NSDictionary *levelData = [NSDictionary dictionaryWithContentsOfFile:levelPlist];
        
        // Height at which the player ends the level
        int endLevelY = [levelData[@"EndY"] intValue];
        
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
                PlatformType type = [platformPoint[@"type"] intValue];
                
                PlatformNode *platformNode = [self createPlatformAtPosition:CGPointMake(x + patternX, y + patternY) ofType:type];
                [_foregroundNode addChild:platformNode];
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
                StarType type = [starPoint[@"type"] intValue];
                
                StarNode *starNode = [self createStarAtPosition:CGPointMake(x + patternX, y + patternY) ofType:type];
                [_foregroundNode addChild:starNode];
            }
        }
        
        // Add the player
        _player = [[Player alloc] init];
        [_player setPosition:CGPointMake(160.0f, 80.0f)];
        _player.goalLineY = endLevelY;
        _player.categoryBitMask = CollisionCategoryPlayer;
        _player.contactTestBitMask = CollisionCategoryStar | CollisionCategoryPlatform;
        [_foregroundNode addChild:_player];
        
        // Tap to Start
        _tapToStartNode = [SKSpriteNode spriteNodeWithImageNamed:@"TapToStart"];
        _tapToStartNode.position = CGPointMake(160, 180.0f);
        [_hudNode addChild:_tapToStartNode];
        
        // Build the HUD
        
        // Stars
        // 1
        SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"Star"];
        star.position = CGPointMake(25, self.size.height - 30);
        [_hudNode addChild:star];
        // 2
        _lblStars = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        _lblStars.fontSize = 30;
        _lblStars.fontColor = [SKColor whiteColor];
        _lblStars.position = CGPointMake(50, self.size.height - 40);
        _lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        // 3
        [_lblStars setText:[NSString stringWithFormat:@"X %d", [GameState sharedInstance].stars]];
        [_hudNode addChild:_lblStars];
        
        // Score
        // 4
        _lblScore = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        _lblScore.fontSize = 30;
        _lblScore.fontColor = [SKColor whiteColor];
        _lblScore.position = CGPointMake(self.size.width - 20, self.size.height - 40);
        _lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        // 5
        [_lblScore setText:@"0"];
        [_hudNode addChild:_lblScore];
        
        // CoreMotion
        _motionManager = [[CMMotionManager alloc] init];
        // 1
        _motionManager.accelerometerUpdateInterval = 0.2;
        // 2
        [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
            // 3
            CMAcceleration acceleration = accelerometerData.acceleration;
            // 4
            _xAcceleration = (acceleration.x * 0.75) + (_xAcceleration * 0.25);
        }];
    }
    return self;
}

- (SKNode *)createBackgroundNode {
    // 1
    // Create the node
    SKNode *backgroundNode = [SKNode node];
    
    // 2
    // Go through images until the entire background is built
    for (int nodeCount = 0; nodeCount < 20; nodeCount++) {
        // 3
        NSString *backgroundImageName = [NSString stringWithFormat:@"Background%02d", nodeCount+1];
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:backgroundImageName];
        // 4
        node.anchorPoint = CGPointMake(0.5f, 0.0f);
        
        //        CGFloat aspect = node.size.width / node.size.height;
        CGFloat scale =  self.size.width / node.size.width;
        CGSize newSize = CGSizeMake(self.size.width, node.size.height * scale);
        node.size = newSize;
        node.position = CGPointMake(self.size.width / 2, nodeCount * node.size.height);
        // 5
        [backgroundNode addChild:node];
    }
    
    // 6
    // Return the completed background node
    return backgroundNode;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // 1
    // If we're already playing, ignore touches
    if ([GameState sharedInstance].started) return;
    
    [GameState sharedInstance].started = true;
    
    // 2
    // Remove the Tap to Start node
    [_tapToStartNode removeFromParent];
    
    [_player startjumping];
}

- (StarNode *)createStarAtPosition:(CGPoint)position ofType:(StarType)type {
    // 1
    StarNode *node = [[StarNode alloc] initWithType:type];
    [node setPosition:position];
    [node setName:@"NODE_STAR"];
    node.categoryBitMask = CollisionCategoryStar;
    
    return node;
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    // 1
    BOOL updateHUD = NO;
    
    // 2
    SKNode *other = (contact.bodyA.node != _player) ? contact.bodyA.node : contact.bodyB.node;
    
    // 3
    updateHUD = [(GameObjectNode *)other collisionWithPlayer:_player];
    
    // Update the HUD if necessary
    if (updateHUD) {
        // 4 TODO: Update HUD in Part 2
        [_lblStars setText:[NSString stringWithFormat:@"X %d", [GameState sharedInstance].stars]];
        [_lblScore setText:[NSString stringWithFormat:@"%d", [GameState sharedInstance].score]];
    }
}

- (PlatformNode *)createPlatformAtPosition:(CGPoint)position ofType:(PlatformType)type {
    // 1
    PlatformNode *node = [[PlatformNode alloc] initWithType:type];
    [node setPosition:position];
    [node setName:@"NODE_PLATFORM"];
    node.categoryBitMask = CollisionCategoryPlatform;
    
    return node;
}

- (SKNode *)createMidgroundNode {
    // Create the node
    SKNode *midgroundNode = [SKNode node];
    
    // 1
    // Add some branches to the midground
    for (int i = 0; i < 10; i++) {
        NSString *spriteName;
        // 2
        int r = arc4random() % 2;
        if (r > 0) {
            spriteName = @"BranchRight";
        } else {
            spriteName = @"BranchLeft";
        }
        // 3
        SKSpriteNode *branchNode = [SKSpriteNode spriteNodeWithImageNamed:spriteName];
        branchNode.position = CGPointMake(160.0f, 500.0f * i);
        [midgroundNode addChild:branchNode];
    }
    
    // Return the completed background node
    return midgroundNode;
}

- (void)update:(CFTimeInterval)currentTime {
    
    if (![GameState sharedInstance].started) return;
    
    if ((int)_player.position.y - _player.maxPlayerY > 0) {
        // 2
        [GameState sharedInstance].score += (int)_player.position.y - _player.maxPlayerY;
        [_lblScore setText:[NSString stringWithFormat:@"%d", [GameState sharedInstance].score]];
    }
    
    [_player updateStatus];
    
    // Remove game objects that have passed by
    [_foregroundNode enumerateChildNodesWithName:@"NODE_PLATFORM" usingBlock:^(SKNode *node, BOOL *stop) {
        [((PlatformNode *)node) checkNodeRemoval:_player.position.y];
    }];
    [_foregroundNode enumerateChildNodesWithName:@"NODE_STAR" usingBlock:^(SKNode *node, BOOL *stop) {
        [((StarNode *)node) checkNodeRemoval:_player.position.y];
    }];
    
    // Calculate player y offset
    if (_player.position.y > 200.0f) {
        _backgroundNode.position = CGPointMake(0.0f, -((_player.position.y - 200.0f) / 10));
        _midgroundNode.position = CGPointMake(0.0f, -((_player.position.y - 200.0f) / 4));
        _foregroundNode.position = CGPointMake(0.0f, -(_player.position.y - 200.0f));
    }
    
    // 1
    // Check if we've finished the level
    if (_player.arrivedGoalLine) {
        [self endGame];
    }
    
    // 2
    // Check if we've fallen too far
    if (_player.lostLife) {
        [self endGame];
    }
}

- (void)didSimulatePhysics {
    // 1
    // Set velocity based on x-axis acceleration
    [_player updateVelocityXwithXAcceleration:_xAcceleration];
    
    // 2
    // Check x bounds
    if (_player.position.x < -20.0f) {
        _player.position = CGPointMake(self.size.width - 20, _player.position.y);
    } else if (_player.position.x > self.size.width - 20) {
        _player.position = CGPointMake(-20.0f, _player.position.y);
    }
    return;
}

- (void)endGame {
    // 1
    [GameState sharedInstance].started = NO;
    
    // 2
    // Save stars and high score
    [[GameState sharedInstance] saveState];
    
    // 3
    SKScene *endGameScene = [[EndGameScene alloc] initWithSize:self.size];
    SKTransition *reveal = [SKTransition fadeWithDuration:0.5];
    [self.view presentScene:endGameScene transition:reveal];
}

@end
