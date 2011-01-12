/*
 *  TSPositionColorTex1Shader.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/13/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#import "TSShader.h"
#import "TSTexture.h"

class TSPositionColorTex1Shader : public TSShader {
public:
	static TSPositionColorTex1Shader* instance;
	static TSPositionColorTex1Shader* getInstance();
	
	TSPositionColorTex1Shader();
	~TSPositionColorTex1Shader();
	
	TSTexture* texture1;
	virtual void setActive();
};