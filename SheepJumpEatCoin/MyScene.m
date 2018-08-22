#import "MyScene.h"
#import "StarNode.h"
#import "PlatformNode.h"
#import <CoreMotion/CoreMotion.h>
#import "EndGameScene.h"
#import "GameState.h"

typedef NS_OPTIONS(uint32_t, CollisionCategory)
{
  CollisionCategoryPlayer   = 0x1 << 0,
  CollisionCategoryStar     = 0x1 << 1,
  CollisionCategoryPlatform = 0x1 << 2,
};

@interface MyScene () <SKPhysicsContactDelegate>
{
  // Layered Nodes
  SKNode *_backgroundNode;
  SKNode *_midgroundNode;
  SKNode *_foregroundNode;
  SKNode *_hudNode;
  
  // Player
  SKNode *_player;
  // Tap To Start node
  SKSpriteNode *_tapToStartNode;
  
  // Height at which level ends
  int _endLevelY;
  
  // Motion manager for accelerometer
  CMMotionManager *_motionManager;
  
  // Acceleration value from accelerometer
  CGFloat _xAcceleration;
  
  // Labels for score and stars
  SKLabelNode *_lblScore;
  SKLabelNode *_lblStars;
  
  // Max y reached by player
  int _maxPlayerY;
  
  // Game over dude !
  BOOL _gameOver;
}
@end

@implementation MyScene

- (id) initWithSize:(CGSize)size
{
  if (self = [super initWithSize:size]) {
    self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    // Reset
    _maxPlayerY = 80;
    
    [GameState sharedInstance].score = 0;
    _gameOver = NO;
    
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
    _endLevelY = [levelData[@"EndY"] intValue];
    
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
        
        PlatformNode *platformNode = [self createPlatformAtPosition:CGPointMake(x + patternX, y + patternY)
                                                             ofType:type];
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
    _player = [self createPlayer];
    [_foregroundNode addChild:_player];
    
    // Tap to Start
    _tapToStartNode = [SKSpriteNode spriteNodeWithImageNamed:@"TapToStart"];
    _tapToStartNode.position = CGPointMake(160, 180.0f);
    [_hudNode addChild:_tapToStartNode];
    
    // Build the HUD
    
    // Stars
    // 1
    SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"Star"];
    star.position = CGPointMake(25, self.size.height-30);
    [_hudNode addChild:star];
    // 2
    _lblStars = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
    _lblStars.fontSize = 30;
    _lblStars.fontColor = [SKColor whiteColor];
    _lblStars.position = CGPointMake(50, self.size.height-40);
    _lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    // 3
    [_lblStars setText:[NSString stringWithFormat:@"X %d", [GameState sharedInstance].stars]];
    [_hudNode addChild:_lblStars];
    
    // Score
    // 4
    _lblScore = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
    _lblScore.fontSize = 30;
    _lblScore.fontColor = [SKColor whiteColor];
    _lblScore.position = CGPointMake(self.size.width-20, self.size.height-40);
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

- (SKNode *) createBackgroundNode
{
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
    node.position = CGPointMake(160.0f, nodeCount*64.0f);
    // 5
    [backgroundNode addChild:node];
  }
  
  // 6
  // Return the completed background node
  return backgroundNode;
}

- (SKNode *) createPlayer
{
  SKNode *playerNode = [SKNode node];
  [playerNode setPosition:CGPointMake(160.0f, 80.0f)];
  
  SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"sheep_jump1"];
    sprite.size = CGSizeMake(50, 50);
  [playerNode addChild:sprite];
  
  // 1
  playerNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
  // 2
  playerNode.physicsBody.dynamic = NO;
  // 3
  playerNode.physicsBody.allowsRotation = NO;
  // 4
  playerNode.physicsBody.restitution = 1.0f;
  playerNode.physicsBody.friction = 0.0f;
  playerNode.physicsBody.angularDamping = 0.0f;
  playerNode.physicsBody.linearDamping = 0.0f;
  
  // 1
  playerNode.physicsBody.usesPreciseCollisionDetection = YES;
  // 2
  playerNode.physicsBody.categoryBitMask = CollisionCategoryPlayer;
  // 3
  playerNode.physicsBody.collisionBitMask = 0;
  // 4
  playerNode.physicsBody.contactTestBitMask = CollisionCategoryStar | CollisionCategoryPlatform;
  
  return playerNode;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  // 1
  // If we're already playing, ignore touches
  if (_player.physicsBody.dynamic) return;
  
  // 2
  // Remove the Tap to Start node
  [_tapToStartNode removeFromParent];
  
  // 3
  // Start the player by putting them into the physics simulation
  _player.physicsBody.dynamic = YES;
  // 4
  [_player.physicsBody applyImpulse:CGVectorMake(0.0f, 20.0f)];
}

- (StarNode *) createStarAtPosition:(CGPoint)position ofType:(StarType)type
{
  // 1
  StarNode *node = [StarNode node];
  [node setPosition:position];
  [node setName:@"NODE_STAR"];
  
  // 2
  [node setStarType:type];
  SKSpriteNode *sprite;
  if (type == STAR_SPECIAL) {
    sprite = [SKSpriteNode spriteNodeWithImageNamed:@"StarSpecial"];
  } else {
    sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Star"];
  }
  [node addChild:sprite];
  
  // 3
  node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
  
  // 4
  node.physicsBody.dynamic = NO;
  
  node.physicsBody.categoryBitMask = CollisionCategoryStar;
  node.physicsBody.collisionBitMask = 0;
  node.physicsBody.contactTestBitMask = 0;
  
  return node;
}

- (void) didBeginContact:(SKPhysicsContact *)contact
{
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

- (PlatformNode *) createPlatformAtPosition:(CGPoint)position ofType:(PlatformType)type
{
  // 1
  PlatformNode *node = [PlatformNode node];
  [node setPosition:position];
  [node setName:@"NODE_PLATFORM"];
  [node setPlatformType:type];
  
  // 2
  SKSpriteNode *sprite;
  if (type == PLATFORM_BREAK) {
    sprite = [SKSpriteNode spriteNodeWithImageNamed:@"PlatformBreak"];
  } else {
    sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Platform"];
  }
  [node addChild:sprite];
  
  // 3
  node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
  node.physicsBody.dynamic = NO;
  node.physicsBody.categoryBitMask = CollisionCategoryPlatform;
  node.physicsBody.collisionBitMask = 0;
  
  return node;
}

- (SKNode *) createMidgroundNode
{
  // Create the node
  SKNode *midgroundNode = [SKNode node];
  
  // 1
  // Add some branches to the midground
  for (int i=0; i<10; i++) {
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

- (void) update:(CFTimeInterval)currentTime {
  
  if (_gameOver) return;
  
  // New max height ?
  // 1
  if ((int)_player.position.y > _maxPlayerY) {
    // 2
    [GameState sharedInstance].score += (int)_player.position.y - _maxPlayerY;
    // 3
    _maxPlayerY = (int)_player.position.y;
    // 4
    [_lblScore setText:[NSString stringWithFormat:@"%d", [GameState sharedInstance].score]];
  }
  
  // Remove game objects that have passed by
  [_foregroundNode enumerateChildNodesWithName:@"NODE_PLATFORM" usingBlock:^(SKNode *node, BOOL *stop) {
    [((PlatformNode *)node) checkNodeRemoval:_player.position.y];
  }];
  [_foregroundNode enumerateChildNodesWithName:@"NODE_STAR" usingBlock:^(SKNode *node, BOOL *stop) {
    [((StarNode *)node) checkNodeRemoval:_player.position.y];
  }];
  
  // Calculate player y offset
  if (_player.position.y > 200.0f) {
    _backgroundNode.position = CGPointMake(0.0f, -((_player.position.y - 200.0f)/10));
    _midgroundNode.position = CGPointMake(0.0f, -((_player.position.y - 200.0f)/4));
    _foregroundNode.position = CGPointMake(0.0f, -(_player.position.y - 200.0f));
  }
  
  // 1
  // Check if we've finished the level
  if (_player.position.y > _endLevelY) {
    [self endGame];
  }
  
  // 2
  // Check if we've fallen too far
  if (_player.position.y < (_maxPlayerY - 400)) {
    [self endGame];
  }
}

- (void) didSimulatePhysics
{
  // 1
  // Set velocity based on x-axis acceleration
  _player.physicsBody.velocity = CGVectorMake(_xAcceleration * 400.0f, _player.physicsBody.velocity.dy);
  
  // 2
  // Check x bounds
  if (_player.position.x < -20.0f) {
    _player.position = CGPointMake(340.0f, _player.position.y);
  } else if (_player.position.x > 340.0f) {
    _player.position = CGPointMake(-20.0f, _player.position.y);
  }
  return;
}

- (void) endGame
{
  // 1
  _gameOver = YES;
  
  // 2
  // Save stars and high score
  [[GameState sharedInstance] saveState];
  
  // 3
  SKScene *endGameScene = [[EndGameScene alloc] initWithSize:self.size];
  SKTransition *reveal = [SKTransition fadeWithDuration:0.5];
  [self.view presentScene:endGameScene transition:reveal];
}

@end