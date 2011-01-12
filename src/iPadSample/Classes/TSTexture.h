/*
 *  TSTexture.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/13/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

class TSTexture {
public:
	TSTexture(int textureHandle) {this->textureHandle = textureHandle;}
	TSTexture(char* texturePath);
	~TSTexture();

	GLuint initWithData(const void* data, int width, int height);
	GLuint loadImage(char* imagePath);
	
	int width;
	int height;
	
	GLuint textureHandle;
};