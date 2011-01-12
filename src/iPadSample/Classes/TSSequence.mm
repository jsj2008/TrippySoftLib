/*
 *  TSSequence.mm
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/12/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

using namespace std;

#include "TSSequence.h"
#include "TSVertex.h"
#include "TSTexture.h"
#include "Game.h"

GLuint TSSequence::buffersVBO[2]; //0: vertex  1: indices
static bool firstTime = true;

TSSequence::TSSequence(char* sequencePath) {
	frames.push_back(new TSTexture(sequencePath));
	width = frames[0]->width;
	height = frames[0]->height;
	
	if(firstTime)
		glGenBuffers(2, buffersVBO);
	firstTime = false;
	
	this->sequencePath = sequencePath;
}

TSSequence::~TSSequence() {
	delete frames[0];
	frames.clear();
	glDeleteBuffers(2, buffersVBO);
}

void TSSequence::render(int x, int y, float rotation, int frame, GLuint color, TSMatrix* matrix) {
	
	TSRect sourceRect(0.0f, 0.0f, 1.0f, 1.0f);
	TSRect destinationRect((float)x / ScreenWidth, 
						   (float)y / ScreenHeight,
						   (float)(x + width) / ScreenWidth,
						   (float)(y + height) / ScreenHeight);

   render(&sourceRect, &destinationRect, frame, color, matrix);
}
	
void TSSequence::render(TSRect* sourceRect, TSRect* destinationRect, int frame, GLuint color, TSMatrix* matrix) {
	
	// Create vertex/index buffer data
	TSTex1Vertex vertices[4];
	
	vertices[0].color = color;
	vertices[1].color = color;
	vertices[2].color = color;
	vertices[3].color = color;
	
	vertices[0].texCoord1[0] = sourceRect->x1; // top left
	vertices[0].texCoord1[1] = sourceRect->y1;
	vertices[1].texCoord1[0] = sourceRect->x1; // bottom left
	vertices[1].texCoord1[1] = sourceRect->y2;
	vertices[2].texCoord1[0] = sourceRect->x2; // top right
	vertices[2].texCoord1[1] = sourceRect->y1;
	vertices[3].texCoord1[0] = sourceRect->x2; // bottom right
	vertices[3].texCoord1[1] = sourceRect->y2;
	
	vertices[0].position[0] = destinationRect->y1; // top left
	vertices[0].position[1] = destinationRect->x1;
	vertices[1].position[0] = destinationRect->y2; // bottom left
	vertices[1].position[1] = destinationRect->x1;
	vertices[2].position[0] = destinationRect->y1; // top right
	vertices[2].position[1] = destinationRect->x2;
	vertices[3].position[0] = destinationRect->y2; // bottom right
	vertices[3].position[1] = destinationRect->x2;
	
	static const GLushort indices[] = {
		0, 1, 2, 3, 2, 1
	};
	
	// Use VBO for vertex/index data
	glBindBuffer(GL_ARRAY_BUFFER, buffersVBO[0]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(TSTex1Vertex) * 4, vertices, GL_STREAM_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffersVBO[1]);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort) * 6, indices, GL_STREAM_DRAW);
	
	TSPositionColorTex1Shader::getInstance()->texture1 = frames[0];
	TSPositionColorTex1Shader::getInstance()->setActive();
	
    // Perform render operation
	glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, NULL); 
}
