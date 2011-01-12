/*
 *  TSPositionColorTex0Shader.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/13/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#import "TSShader.h"
#import "TSTexture.h"

class TSPositionColorTex0Shader : public TSShader {
public:
	static TSPositionColorTex0Shader* instance;
	static TSPositionColorTex0Shader* getInstance();
	
	TSPositionColorTex0Shader();
	~TSPositionColorTex0Shader();
	
	TSTexture* texture1;
	virtual void setActive();
};