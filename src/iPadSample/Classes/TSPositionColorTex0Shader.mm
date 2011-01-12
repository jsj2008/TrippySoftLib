/*
 *  TSPositionColorTex0Shader.mm
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/13/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#include "TSPositionColorTex0Shader.h"
#include "TSVertex.h"

TSPositionColorTex0Shader* TSPositionColorTex0Shader::instance = NULL;

TSPositionColorTex0Shader* TSPositionColorTex0Shader::getInstance() {
	if(!instance) instance = new TSPositionColorTex0Shader();
	
	return instance;
}

TSPositionColorTex0Shader::TSPositionColorTex0Shader() : TSShader(@"ShaderNoTex") {
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(program, ATTRIB_COLOR, "color");
	
	complete();
}

TSPositionColorTex0Shader::~TSPositionColorTex0Shader() {
}

void TSPositionColorTex0Shader::setActive() {
	TSShader::setActive();
	
	applyTSTex0VertexAttributes();
}