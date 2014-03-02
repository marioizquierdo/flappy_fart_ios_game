#import "FFGameOverScene.h"
#import "FFMyScene.h"

@interface FFGameOverScene ()
@property (nonatomic) BOOL readyToPlayAgain;
@property (nonatomic) NSTimeInterval timeSinceInitTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@end

@implementation FFGameOverScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.readyToPlayAgain = NO;
        self.timeSinceInitTimeInterval = 0.0;
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        NSString * message = @"Again?";
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter-CondensedBold"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
    }
    return self;
}

- (void)update:(NSTimeInterval)currentTime {
    if (!self.lastUpdateTimeInterval) self.lastUpdateTimeInterval = currentTime;
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    self.timeSinceInitTimeInterval += timeSinceLast;

    // Handle time delta.
    if (self.timeSinceInitTimeInterval > 0.1) {
        self.readyToPlayAgain = YES; // wait a little before allowing to play another game
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.readyToPlayAgain) {
        [self runAction:
            [SKAction runBlock:^{
                SKScene * myScene = [[FFMyScene alloc] initWithSize:self.size];
                [self.view presentScene:myScene];
            }]
         ];
    }
}

@end