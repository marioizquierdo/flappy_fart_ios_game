#import "FFMyScene.h"
#import "FFContants.h"

#import "FFPlayer.h"

@interface FFPlayer ()

@property (nonatomic) FFMyScene *myscene;
@property (nonatomic) BOOL isFarting;
@property (nonatomic) NSTimeInterval lastFartTimeInterval;

@end

@implementation FFPlayer

+(FFPlayer *) buildPlayerForScene:(FFMyScene *)scene {
    FFPlayer *player = [[FFPlayer alloc] initWithScene:scene];
    return player;
}

-(id)initWithScene:(FFMyScene *)scene {
    if (self = [super initWithTexture:scene.playerTextures[@"player_default"]]) {
        NSLog(@"Player size: %fx%f", self.size.width, self.size.height);
        self.isFarting = NO;
        self.position = CGPointMake(self.size.width*2, scene.frame.size.height/2);
        
        // Apply physics
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:3*self.size.width/4]; // aprox as circle shape
        self.physicsBody.mass = 1;
        self.physicsBody.categoryBitMask = PLAYER_BITMASK;
        self.physicsBody.contactTestBitMask = FOOD_BITMASK;
        self.physicsBody.collisionBitMask = 0;
        
        self.myscene = scene;
    }
    return self;
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    
    // Change player animation texture
    SKTexture *texture;
    if (self.isFarting) {
        texture = self.myscene.playerTextures[@"player_farting"];
    } else {
        if (self.physicsBody.velocity.dy > 0) {
            texture = self.myscene.playerTextures[@"player_up"];
        } else {
            texture = self.myscene.playerTextures[@"player_down"];
        }
    }
    if (texture && self.texture != texture) {
        SKAction *setTexture = [SKAction setTexture: texture];
        [self runAction:setTexture];
    }
    
    // Farting duration
    self.lastFartTimeInterval += timeSinceLast;
    if (self.lastFartTimeInterval > .2) {
        self.isFarting = NO;
    }
}

- (void) fart {
    self.physicsBody.velocity = CGVectorMake(0, 0);
    [self.physicsBody applyImpulse:CGVectorMake(0.0, 500.0)];
    self.isFarting = YES;
    self.lastFartTimeInterval = 0.0;
}

@end
