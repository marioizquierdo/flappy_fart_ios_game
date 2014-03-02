#import <SpriteKit/SpriteKit.h>

@interface FFPlayer : SKSpriteNode

+(FFPlayer *) buildPlayerForScene:(FFMyScene *)scene; // singleton instance

- (id)initWithScene:(FFMyScene *)scene;

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast;
- (void) fart;

@end
