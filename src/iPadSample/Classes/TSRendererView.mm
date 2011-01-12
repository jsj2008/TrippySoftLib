//
//  EAGLView.m
//  iPadSample
//
//  Created by Timothy Kerchmar on 11/30/10.
//  Copyright 2010 The Night School, LLC. All rights reserved.
//

using namespace std;

#include "TSRenderer.h"
#import "TSRendererView.h"
#include "Game.h"

@implementation TSRendererView

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{   
	if ((self = [super initWithFrame: frame])) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
		
		self.userInteractionEnabled = YES;
		self.multipleTouchEnabled = YES;
    }
    
    return self;
}

- (void)drawFrame {
	TSRenderer::instance->drawFrame();
}

-(void) touches:(NSSet*)touches withEvent:(UIEvent*)event withTouchType:(unsigned int)idx;
{
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	Game::getInstance()->dragSpeed.SetZero();
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* singleTouch = [touches anyObject];
	CGPoint newTouchLocation = [singleTouch locationInView: [singleTouch view]];	
	CGPoint oldTouchLocation = [singleTouch previousLocationInView: [singleTouch view]];
	
	Game::getInstance()->amountDragged += b2Vec2(oldTouchLocation.y - newTouchLocation.y, newTouchLocation.x - oldTouchLocation.x);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
