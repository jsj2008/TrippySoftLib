/*
 *  TSVertex.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/12/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

typedef struct TSVertex
{
	GLfloat	position[2];
	GLuint color;
};

typedef struct TSTex1Vertex {
	GLfloat position[2];
	GLuint color;
	GLfloat texCoord1[2];
};

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
	ATTRIB_TEX1,
    NUM_ATTRIBUTES
};

void applyTSTex0VertexAttributes();
void applyTSTex1VertexAttributes();
