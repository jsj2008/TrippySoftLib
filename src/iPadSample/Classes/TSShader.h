/*
 *  TSShader.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/12/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

// This class is to abstract away all basic shader loading scaffolding.
class TSShader {
public:
	TSShader(NSString* shaderName);
	~TSShader();
	
	virtual void setActive();
	
	BOOL compileShader(GLuint *shader, GLenum type, NSString * file);
	BOOL linkProgram(GLuint prog);
	BOOL validateProgram(GLuint prog);
	BOOL loadShaders(NSString* shaderName);
	BOOL complete();
	
    GLuint program;
	
	// NULL after linkProgram
    GLuint vertShader, fragShader;
};