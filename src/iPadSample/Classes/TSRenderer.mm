/*
 *  TSRenderer.mm
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/1/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

using namespace std;

#include "TSRenderer.h"
#include "Game.h"
#include "texture2d.h"
#import "TSVertex.h"

TSRenderer* TSRenderer::instance = 0;

TSRenderer::TSRenderer() {
	instance = this;
	
	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	if (!context) {
		NSLog(@"Failed to create ES2 context");
		return;
	}
	
	NSString *reqSysVer = @"3.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	if ([currSysVer compare:reqSysVer options:NSNumericSearch] == NSOrderedAscending) {
		NSLog(@"This application requires iOS 3.1 or greater");
		return;
	}
	
	view = [[TSRendererView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	createFramebuffer();
}

TSRenderer::~TSRenderer() {
    deleteFramebuffer();
	[context release];
	[view release];
}

void TSRenderer::startAnimation() {
	/*
	 CADisplayLink is API new in iOS 3.1. Compiling against earlier versions will result in a warning, but can be dismissed if the system version runtime check for CADisplayLink exists in -awakeFromNib. The runtime check ensures this code will not be called in system versions earlier than 3.1.
	 */
	displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:view selector:@selector(drawFrame)];
	[displayLink setFrameInterval:1];
	
	// The run loop will retain the display link on add.
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

void TSRenderer::stopAnimation() {
	[displayLink invalidate];
	displayLink = nil;
}

void drawText(NSString* theString, float X, float Y) {
	// Set up texture
	Texture2D* statusTexture = [[[Texture2D alloc] initWithString:theString dimensions:CGSizeMake(150, 150) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:14] autorelease];
	
	// Create vertex/index buffer data
	TSTex1Vertex vertices[4];
	
	GLuint color = 0xFFFFFFFF;
	
	vertices[0].color = color;
	vertices[1].color = color;
	vertices[2].color = color;
	vertices[3].color = color;
	
	vertices[0].texCoord1[0] = 0.0f; // top left
	vertices[0].texCoord1[1] = 0.0f;
	vertices[1].texCoord1[0] = 0.0f; // bottom left
	vertices[1].texCoord1[1] = 1.0f;
	vertices[2].texCoord1[0] = 1.0f; // top right
	vertices[2].texCoord1[1] = 0.0f;
	vertices[3].texCoord1[0] = 1.0f; // bottom right
	vertices[3].texCoord1[1] = 1.0f;
	
	vertices[0].position[0] = Y; // top left
	vertices[0].position[1] = X;
	vertices[1].position[0] = Y + statusTexture.pixelsWide / 384.0f; // bottom left
	vertices[1].position[1] = X;
	vertices[2].position[0] = Y; // top right
	vertices[2].position[1] = X + statusTexture.pixelsWide / 512.0f;
	vertices[3].position[0] = Y + statusTexture.pixelsWide / 384.0f; // bottom right
	vertices[3].position[1] = X + statusTexture.pixelsWide / 512.0f;
	
	static const GLushort indices[] = {
		0, 1, 2, 3, 2, 1
	};
	
	GLuint buffersVBO[2];
	glGenBuffers(2, buffersVBO);
	
	// Use VBO for vertex/index data
	glBindBuffer(GL_ARRAY_BUFFER, buffersVBO[0]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(TSTex1Vertex) * 4, vertices, GL_STREAM_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffersVBO[1]);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort) * 6, indices, GL_STREAM_DRAW);
	
	TSTexture texture(statusTexture.name);
	
	TSPositionColorTex1Shader::getInstance()->texture1 = &texture;
	TSPositionColorTex1Shader::getInstance()->setActive();
	
    // Perform render operation
	glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, NULL); 
	
	glDeleteBuffers(2, buffersVBO);
}

double OldTime = CACurrentMediaTime();
void TSRenderer::drawFrame() {
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
	
	Game::getInstance()->update();
	
	double CurrentTime = CACurrentMediaTime();
	drawText([NSString stringWithFormat:@"fps: %.1f", 1.0 / (CurrentTime - OldTime)], 0.7f, -1.0f);
	OldTime = CurrentTime;
    
	[context presentRenderbuffer:GL_RENDERBUFFER];
}

void TSRenderer::createFramebuffer() {
	[EAGLContext setCurrentContext:context];
	
	// Create default framebuffer object.
	glGenFramebuffers(1, &defaultFramebuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
	
	// Create color render buffer and allocate backing store.
	glGenRenderbuffers(1, &colorRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)view.layer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
	
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
	
	if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
		NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
	
	glViewport(0, 0, framebufferWidth, framebufferHeight);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

void TSRenderer::deleteFramebuffer() {
	[EAGLContext setCurrentContext:context];
	
	glDeleteFramebuffers(1, &defaultFramebuffer);
	defaultFramebuffer = 0;
	
	glDeleteRenderbuffers(1, &colorRenderbuffer);
	colorRenderbuffer = 0;
}
