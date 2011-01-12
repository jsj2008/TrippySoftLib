/*
 *  TSTexture.mm
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/13/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#include "TSTexture.h"

GLuint TSTexture::initWithData(const void* data, int width, int height) {
	this->width = width;
	this->height = height;
	
	GLuint textureHandle;
	glGenTextures(1, &textureHandle);
	//		glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
	glBindTexture(GL_TEXTURE_2D, textureHandle);
	
	//GL_NEAREST
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	// Specify OpenGL texture image
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
	
	return textureHandle;
}

@implementation UIImage(imageNamed_Hack)

+ (UIImage *)imageNamed:(NSString *)name {
	
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], name ]];
}

@end

GLuint TSTexture::loadImage(char* imagePath) {
	NSAutoreleasePool * myPool = [[NSAutoreleasePool alloc] init];
	
	UIImage* uiImage = [UIImage imageNamed:[NSString stringWithCString:imagePath]];
	
	NSUInteger				width,
	height,
	i;
	CGContextRef			context = nil;
	void*					data = nil;;
	CGColorSpaceRef			colorSpace;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	CGSize					imageSize;
	CGImageRef				image;
	BOOL					sizeToFit = NO;
	
	image = [uiImage CGImage];
	
	if(image == NULL) {
		NSLog(@"Image is Null");
		return nil;
	}
	
	info = CGImageGetAlphaInfo(image);
	hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
	
	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	transform = CGAffineTransformIdentity;
	
	width = imageSize.width;
	
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < width)
			i *= 2;
		width = i;
	}
	height = imageSize.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < height)
			i *= 2;
		height = i;
	}
	
	GLint maxTextureSize;
	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);
	if( width > maxTextureSize || height > maxTextureSize ) {
		NSLog(@"WARNING: Image (%d x %d) is bigger than the supported %d x %d", width, height, maxTextureSize, maxTextureSize);
		return nil;
	}
	
	//	while((width > kMaxTextureSize) || (height > kMaxTextureSize)) {
	//		width /= 2;
	//		height /= 2;
	//		transform = CGAffineTransformScale(transform, 0.5f, 0.5f);
	//		imageSize.width *= 0.5f;
	//		imageSize.height *= 0.5f;
	//	}
	
	// Create the bitmap graphics context
	colorSpace = CGColorSpaceCreateDeviceRGB();
	data = malloc(height * width * 4);
	info = hasAlpha ? kCGImageAlphaPremultipliedLast : kCGImageAlphaNoneSkipLast; 
	context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, info | kCGBitmapByteOrder32Big);				
	CGColorSpaceRelease(colorSpace);
	
	CGContextClearRect(context, CGRectMake(0, 0, width, height));
	CGContextTranslateCTM(context, 0, height - imageSize.height);
	
	if(!CGAffineTransformIsIdentity(transform))
		CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
	
	GLuint textureHandle = initWithData(data, width, height);
	
	CGContextRelease(context);
	free(data);
	uiImage = nil;
	
	[myPool release];
	
	return textureHandle;
}

TSTexture::TSTexture(char* texturePath) {
	textureHandle = loadImage(texturePath);
}

TSTexture::~TSTexture() {
	glDeleteTextures(1, &textureHandle);
}