---
layout: post
title: 'Cocos2d: how to make a label to fit the Iphone screen width'
tags:
- Cocos2d
- iPhone
status: publish
type: post
published: true
meta:
  _edit_last: '1'
excerpt: "Cocos2d: how to make a label to fit the Iphone screen width"
---
<p>In the iPhone game I'm working on I need to display a different label every time I start a new game level. Each one of these labels has a random string taken from an array of words, and each one of these strings has different size. So every time I create a new label I set the maximum font size and then I decrement it until the string size measures less than the iPhone screen. I do that using the <strong>sizeWithFont</strong> method of the <strong>NSString</strong> class:</p>

<pre lang="objc">
- (int) calculateFontSizeForString:(NSString*)string fontName:(NSString*)usedFontName {
  int fontSize = 120; // it seems to be the biggest font we can use
  while (--fontSize > 0) {			
    CGSize size = [string sizeWithFont:[UIFont fontWithName:usedFontName size:fontSize]];
    if (size.width <= 480 && size.height <= 360)
      break;
  }				

  return fontSize;
}
</pre>

<p>And here a custom scene that you can use to test it:</p>
<strong>MyScene.h</strong>
<pre lang="objc">
#import "cocos2d.h"

@interface MyScene : Scene {
  Label    *label;
  NSArray  *strings;
  NSString *fontName;
  int      stringIndex;
}

- (void) nextLabel;
- (int)  calculateFontSizeForString:(NSString*)string fontName:(NSString*)usedFontName;
- (void) removeCurrentLabel;
- (void) createNextLabel;
- (void) animateLabel;

@property (nonatomic, retain) NSArray  *strings;
@property (nonatomic, retain) NSString *fontName;
@end

</pre>
<strong>MyScene.m</strong>
<pre lang="objc">
#import "MyScene.h"

@implementation MyScene

@synthesize strings;
@synthesize fontName;

- (id) init {
  if (self = [super init]) {
    [self setFontName:@"Marker Felt"];
    [self setStrings:[NSArray arrayWithObjects:
                      @"Lorem ipsum", 
                      @"Lorem ipsum dolor",
                      @"Lorem ipsum dolor sit amet",
                      @"Lorem ipsum dolor sit amet, consectetur adipisicing elit",
                      @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                      nil]];		
    stringIndex = 0;
  }
	
  return self;
}

- (void) onEnter {
  [super onEnter];
  [self nextLabel];
}

- (void) nextLabel {	
  [self removeCurrentLabel];
  [self createNextLabel];	
  stringIndex++;	
}

- (void) removeCurrentLabel {
  if (label) [self removeChild:label cleanup:YES];
  label = nil;
}

- (void) createNextLabel {
  NSString *labelString = [strings objectAtIndex:(stringIndex % [strings count])];
  int fontSize = [self calculateFontSizeForString:labelString fontName:fontName];	
  label = [Label labelWithString:labelString dimensions: CGSizeMake(0, 0) alignment: UITextAlignmentCenter fontName:fontName fontSize:fontSize];
  [label setPosition:ccp(240, 160)];	
  [label setScale:0.5];
  [self addChild:label];
  [self animateLabel];	
}

- (void) animateLabel {
  IntervalAction *scale = [ScaleTo actionWithDuration:0.5 scale:1];
  id delay  = [DelayTime actionWithDuration:1]; 
  id notify = [CallFunc actionWithTarget:self selector:@selector(nextLabel)];	
  Sequence *sequence = [Sequence actions:scale, delay, notify, nil];	
  [label runAction:sequence];		
}

- (int) calculateFontSizeForString:(NSString*)string fontName:(NSString*)usedFontName {
  int fontSize = 120; // it seems to be the biggest font we can use
  while (--fontSize > 0) {			
    CGSize size = [string sizeWithFont:[UIFont fontWithName:usedFontName size:fontSize]];
    if (size.width <= 480 && size.height <= 360)
      break;
  }				
	
  return fontSize;
}

- (void) dealloc {
  [strings retain];
  [fontName retain];
  [super dealloc];
}

@end
</pre>

<strong>FitFontTestAppDelegate.m</strong>
<pre lang="objc">
#import "FitFontTestAppDelegate.h"

@implementation FitFontTestAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [window setUserInteractionEnabled:YES];
  [window setMultipleTouchEnabled:YES];
	
  [[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
  [[Director sharedDirector] attachInWindow:window];		
  [window makeKeyAndVisible];	
		
  MyScene *scene = [MyScene node];
  [[Director sharedDirector] runWithScene:scene];
	
}


- (void)dealloc {
  [window release];
  [super dealloc];
}

@end

</pre>
