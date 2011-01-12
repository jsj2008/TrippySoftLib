/*
 *  TSVertex.mm
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/12/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#include "TSVertex.h"

void applyTSTex0VertexAttributes() {
	// Specify vertex data offset/stride/type
	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, sizeof(TSVertex), NULL);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, 1, sizeof(TSVertex), (void*)offsetof(TSVertex, color));
	glEnableVertexAttribArray(ATTRIB_COLOR);
	glDisableVertexAttribArray(ATTRIB_TEX1);
}

void applyTSTex1VertexAttributes() {
	// Specify vertex data offset/stride/type
	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, sizeof(TSTex1Vertex), NULL);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, 1, sizeof(TSTex1Vertex), (void*)offsetof(TSTex1Vertex, color));
	glEnableVertexAttribArray(ATTRIB_COLOR);
	glVertexAttribPointer(ATTRIB_TEX1, 2, GL_FLOAT, 0, sizeof(TSTex1Vertex), (void*)offsetof(TSTex1Vertex, texCoord1));
	glEnableVertexAttribArray(ATTRIB_TEX1);
}
