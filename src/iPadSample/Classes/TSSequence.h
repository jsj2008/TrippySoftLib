/*
 *  TSSequence.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/12/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#ifndef _TSSEQUENCE_H
#define _TSSEQUENCE_H

#include "TSPositionColorTex1Shader.h"
#include "TSMatrix.h"
#include "TSTexture.h"
#include "TSRect.h"
#include <vector>

// This class will closely mimick the AS3 version's API.
class TSSequence {
public:
	TSSequence(char* sequencePath);
	~TSSequence();
	void render(int x, int y, float rotation, int frame, GLuint color, TSMatrix* matrix = NULL);
	void render(TSRect* sourceRect, TSRect* destinationRect, int frame, GLuint color, TSMatrix* matrix = NULL);
	
	static GLuint buffersVBO[2]; //0: vertex  1: indices
	std::vector<TSTexture*> frames;
	char* sequencePath;
	
	int width, height;
};

#endif