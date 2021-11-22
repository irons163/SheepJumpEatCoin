#import "MyScene.h"
#import "StarNode.h"
#import "PlatformNode.h"
#import <CoreMotion/CoreMotion.h>
#import "EndGameScene.h"
#import "GameState.h"
#import "Player.h"
#import "GameLevelLoader.h"

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
        
        GameLevelLoader *levelLoader = [[GameLevelLoader alloc] init];
        levelLoader.platformInfoBlock = ^(CGPoint position, NSInteger type) {
            PlatformNode *platformNode = [self createPlatformAtPosition:position ofType:(PlatformType)type];
            [_foregroundNode addChild:platformNode];
        };
        levelLoader.starInfoBlock = ^(CGPoint position, NSInteger type) {
            StarNode *starNode = [self createStarAtPosition:position ofType:(StarType)type];
            [_foregroundNode addChild:starNode];
        };
        [levelLoader load];
        
        NSInteger endLevelY = levelLoader.endY;
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
        SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"Star"];
        star.position = CGPointMake(25, self.size.height - 30);
        [_hudNode addChild:star];
        
        _lblStars = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        _lblStars.fontSize = 30;
        _lblStars.fontColor = [SKColor whiteColor];
        _lblStars.position = CGPointMake(50, self.size.height - 40);
        _lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        [_lblStars setText:[NSString stringWithFormat:@"X %ld", [GameState sharedInstance].stars]];
        [_hudNode addChild:_lblStars];
        
        _lblScore = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        _lblScore.fontSize = 30;
        _lblScore.fontColor = [SKColor whiteColor];
        _lblScore.position = CGPointMake(self.size.width - 20, self.size.height - 40);
        _lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        [_lblScore setText:@"0"];
        [_hudNode addChild:_lblScore];
        
        // CoreMotion
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 0.2;
        [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
            CMAcceleration acceleration = accelerometerData.acceleration;
            _xAcceleration = (acceleration.x * 0.75) + (_xAcceleration * 0.25);
        }];
    }
    return self;
}

- (SKNode *)createBackgroundNode {
    SKNode *backgroundNode = [SKNode node];
    
    // Go through images until the entire background is built
    for (int nodeCount = 0; nodeCount < 20; nodeCount++) {
        NSString *backgroundImageName = [NSString stringWithFormat:@"Background%02d", nodeCount+1];
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:backgroundImageName];
        node.anchorPoint = CGPointMake(0.5f, 0.0f);
        CGFloat scale =  self.size.width / node.size.width;
        CGSize newSize = CGSizeMake(self.size.width, node.size.height * scale);
        node.size = newSize;
        node.position = CGPointMake(self.size.width / 2, nodeCount * node.size.height);
        [backgroundNode addChild:node];
    }
    
    // Return the completed background node
    return backgroundNode;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // If we're already playing, ignore touches
    if ([GameState sharedInstance].started) return;
    
    [GameState sharedInstance].started = true;
    
    // Remove the Tap to Start node
    [_tapToStartNode removeFromParent];
    
    [_player startjumping];
}

- (StarNode *)createStarAtPosition:(CGPoint)position ofType:(StarType)type {
    StarNode *node = [[StarNode alloc] initWithType:type];
    [node setPosition:position];
    [node setName:@"NODE_STAR"];
    node.categoryBitMask = CollisionCategoryStar;
    
    return node;
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    BOOL updateHUD = NO;
    
    SKNode *other = (contact.bodyA.node != _player) ? contact.bodyA.node : contact.bodyB.node;
    
    updateHUD = [(GameObjectNode *)other collisionWithPlayer:_player];
    
    // Update the HUD if necessary
    if (updateHUD) {
        [_lblStars setText:[NSString stringWithFormat:@"X %ld", [GameState sharedInstance].stars]];
        [_lblScore setText:[NSString stringWithFormat:@"%ld", [GameState sharedInstance].score]];
    }
}

- (PlatformNode *)createPlatformAtPosition:(CGPoint)position ofType:(PlatformType)type {
    PlatformNode *node = [[PlatformNode alloc] initWithType:type];
    [node setPosition:position];
    [node setName:@"NODE_PLATFORM"];
    node.categoryBitMask = CollisionCategoryPlatform;
    
    return node;
}

- (SKNode *)createMidgroundNode {
    SKNode *midgroundNode = [SKNode node];
    
    // Add some branches to the midground
    for (int i = 0; i < 10; i++) {
        NSString *spriteName;
        
        int r = arc4random() % 2;
        if (r > 0) {
            spriteName = @"BranchRight";
        } else {
            spriteName = @"BranchLeft";
        }
        
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
        [GameState sharedInstance].score += (NSInteger)_player.position.y - _player.maxPlayerY;
        [_lblScore setText:[NSString stringWithFormat:@"%ld", [GameState sharedInstance].score]];
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
    
    // Check if we've finished the level
    if (_player.arrivedGoalLine) {
        [self endGame];
    }
    
    // Check if we've fallen too far
    if (_player.lostLife) {
        [self endGame];
    }
}

- (void)didSimulatePhysics {
    // Set velocity based on x-axis acceleration
    [_player updateVelocityXwithXAcceleration:_xAcceleration];
    
    // Check x bounds
    if (_player.position.x < -20.0f) {
        _player.position = CGPointMake(self.size.width - 20, _player.position.y);
    } else if (_player.position.x > self.size.width - 20) {
        _player.position = CGPointMake(-20.0f, _player.position.y);
    }
    return;
}

- (void)endGame {
    [GameState sharedInstance].started = NO;
    // Save stars and high score
    [[GameState sharedInstance] saveState];
    
    SKScene *endGameScene = [[EndGameScene alloc] initWithSize:self.size];
    SKTransition *reveal = [SKTransition fadeWithDuration:0.5];
    [self.view presentScene:endGameScene transition:reveal];
}

@end
