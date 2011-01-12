/*
 *  TSBox2D.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/22/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#ifndef _TSBOX2D_H
#define _TSBOX2D_H

#include <Box2D/Box2D.h>
#include "GLES-Render.h"
#include "TSSequence.h"

class TSBox2D {
public:
	TSBox2D(b2Vec2 gravity);
	~TSBox2D();
	void syncBodiesAndGraphics(float screenX, float screenY, float timeStep);
		
	b2World* world;
//	public var debugSprite:Sprite;
	float drawScale;
	b2Vec2 gravity;
	GLESDebugDraw debugDraw;
	TSSequence* circle;
	b2Body* groundBody;
};

#endif