/*
 *  TSRenderer.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/1/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#import <QuartzCore/QuartzCore.h>
#import "TSRendererView.h"

class TSRenderer {
public:
	TSRenderer();
	~TSRenderer();
	
	void startAnimation();
	void stopAnimation();
	void drawFrame();
	void createFramebuffer();
	void deleteFramebuffer();
					
	TSRendererView* view;
	id displayLink;
	EAGLContext* context;
	
    // The pixel dimensions of the CAEAGLLayer.
    GLint framebufferWidth;
    GLint framebufferHeight;
    
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view.
    GLuint defaultFramebuffer, colorRenderbuffer;
	
	static TSRenderer* instance;
};