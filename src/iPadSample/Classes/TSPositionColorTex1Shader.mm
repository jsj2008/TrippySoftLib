/*
 *  TSPositionColorTex1Shader.mm
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/13/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#include "TSPositionColorTex1Shader.h"
#include "TSVertex.h"

// Uniform index.
enum {
	UNIFORM_TEXTURE1,
    NUM_UNIFORMS
};

GLint uniforms[NUM_UNIFORMS];

TSPositionColorTex1Shader* TSPositionColorTex1Shader::instance = NULL;

TSPositionColorTex1Shader* TSPositionColorTex1Shader::getInstance() {
	if(!instance) instance = new TSPositionColorTex1Shader();
	
	return instance;
}

TSPositionColorTex1Shader::TSPositionColorTex1Shader() : TSShader(@"Shader") {
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(program, ATTRIB_COLOR, "color");
    glBindAttribLocation(program, ATTRIB_TEX1, "texCoord1");
	
	complete();
	
	// associate texture1 sampler with texture slot 0
    uniforms[UNIFORM_TEXTURE1] = glGetUniformLocation(program, "texture1");
	glUniform1i(uniforms[UNIFORM_TEXTURE1], 0);    
}

TSPositionColorTex1Shader::~TSPositionColorTex1Shader() {
}

void TSPositionColorTex1Shader::setActive() {
	TSShader::setActive();
	
	// assign our texture to slot 0
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, texture1->textureHandle);
	
	applyTSTex1VertexAttributes();
}