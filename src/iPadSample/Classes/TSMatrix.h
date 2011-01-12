/*
 *  TSMatrix.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/12/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#ifndef _TSMATRIX_H
#define _TSMATRIX_H

#include <Box2D/Box2D.h>

class TSMatrix {
public:
	TSMatrix(float a = 1.0f, float b = 0.0f, float c = 0.0f, float d = 1.0f, float tx = 0.0f, float ty = 0.0f);
	~TSMatrix();
	
	void translate(float dx, float dy);
	void rotate(float angle);
	void concat(TSMatrix* m);
	
	float a, b, c, d, tx, ty;
	b2Vec2 transformPoint(b2Vec2 point);
};

#endif