#import "FFMyScene.h"
#import "FFGameOverScene.h"
#import "FFContants.h"
#import "FFPlayer.h"

@interface FFMyScene () <SKPhysicsContactDelegate>

@property (nonatomic) FFPlayer *player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@end

@implementation FFMyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // Initialize textures
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
        self.playerTextures = @{
            @"player_default" : [atlas textureNamed:@"player_default.png"],
            @"player_farting" : [atlas textureNamed:@"player_farting.png"],
            @"player_down" :    [atlas textureNamed:@"player_down.png"],
            @"player_up" :      [atlas textureNamed:@"player_up.png"]
        };
        
        NSLog(@"Scene Size: %@", NSStringFromCGSize(size));
        self.backgroundColor = [SKColor colorWithRed:.90 green:.90 blue:1.0 alpha:1.0];
        
        // Add player to the scene and load textures (frames)
        self.player = [FFPlayer buildPlayerForScene:self];
        [self addChild:self.player];
        
        // Set physics world properties
        self.physicsWorld.gravity = CGVectorMake(0,-11);
        self.physicsWorld.contactDelegate = self; // report collisions here
    }
    return self;
}

// Frame Update
- (void)update:(NSTimeInterval)currentTime {
    CFTimeInterval timeSinceLast = [self timeSinceLastUpdate:currentTime];
    
    // Spawn food
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > .8) {
        self.lastSpawnTimeInterval = 0;
        [self addFood];
    }
    
    // Update player animation
    [self.player updateWithTimeSinceLastUpdate:timeSinceLast];
    
    // Check is player is out of bounds
    if (self.player.position.y > (self.frame.size.height + 3*self.player.size.height)
        || self.player.position.y < -3*self.player.size.height) {
        [self gameOver];
    }
}

// Calculate time between frame updates
- (NSTimeInterval) timeSinceLastUpdate:(NSTimeInterval)currentTime {
    if (!self.lastUpdateTimeInterval) self.lastUpdateTimeInterval = currentTime;
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    return timeSinceLast;
}

- (void)addFood {
    
    // Create sprite
    SKSpriteNode * food = [SKSpriteNode spriteNodeWithImageNamed:@"food_1"];
    
    // Apply physics to sprite
    CGSize halfSpriteSize = CGSizeMake(food.size.width/2, food.size.height/2);
    food.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:halfSpriteSize]; // aprox as rectangle shape
    food.physicsBody.dynamic = YES; // do not allow the physics engine to control de movement, we'll do it.
    food.physicsBody.affectedByGravity = NO;
    food.physicsBody.categoryBitMask = FOOD_BITMASK;
    food.physicsBody.contactTestBitMask = PLAYER_BITMASK;
    food.physicsBody.collisionBitMask = 0; // indicates what categories of objects this object that the physics engine handle contact responses to (i.e. bounce off of). We do noghint here (0)
    
    // Determine where to spawn the food along the Y axis
    int minY = food.size.height;
    int maxY = self.frame.size.height - food.size.height;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the food slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    food.position = CGPointMake(self.frame.size.width + food.size.width/2, actualY);
    [self addChild:food];
    
    // Determine speed of the food
    int minDuration = 4.0;
    int maxDuration = 5.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions: move and if the movement is finalized then it means that the player didn't eat it.
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-food.size.width/2, actualY) duration:actualDuration];
    SKAction * loseAction = [SKAction runBlock:^{ [self gameOver]; }];
    [food runAction:[SKAction sequence:@[actionMove, loseAction]]];
}

// TOUCH
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.player fart];
}

// Game Over
-(void)gameOver {
    SKScene * gameOverScene = [[FFGameOverScene alloc] initWithSize:self.size];
    [self.view presentScene:gameOverScene ];
}

// Contact delegate method, to resolve collisions
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // Arrange collided elements
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // Check if they are food and player
    if ((firstBody.categoryBitMask & PLAYER_BITMASK) != 0 && (secondBody.categoryBitMask & FOOD_BITMASK) != 0) {
        [self playerDidCollideWithfood:(SKSpriteNode *) secondBody.node];
    }
}

- (void)playerDidCollideWithfood:(SKSpriteNode *)food {
    NSLog(@"Hit");
    [food removeFromParent];
}


@end
