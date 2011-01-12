/*
 *  TSBox2D.mm
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/22/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#include "Game.h"
#include "TSBox2D.h"

TSBox2D::TSBox2D(b2Vec2 gravity) {
	this->gravity = gravity;
	world = new b2World(b2Vec2(), true);
	//var contactListener = new TSContactListener();
	//world.SetContactListener(contactListener);
	//displayParent.addChild(this);
	
	uint32 flags = 0;
	flags += b2DebugDraw::e_shapeBit;
	flags += b2DebugDraw::e_jointBit;
//	flags += b2DebugDraw::e_aabbBit;
//	flags += b2DebugDraw::e_pairBit;
	flags += b2DebugDraw::e_centerOfMassBit;
	debugDraw.SetFlags(flags);
	
	world->SetDebugDraw(&debugDraw);
	
	b2CircleShape* circle = new b2CircleShape();
	circle->m_radius = 0.1f;
	
	b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	groundBody = world->CreateBody(&bodyDef);
	
	drawScale = 30.0f; // incoming scale from svg pixels to box2d (use 30)
	debugDraw.drawScale = b2Vec2(drawScale * 2.0f / ScreenWidth, drawScale * 2.0f / ScreenHeight); // outgoing scale from box2d to opengl
}

TSBox2D::~TSBox2D() {
	delete world;
}

void TSBox2D::syncBodiesAndGraphics(float screenX, float screenY, float timeStep) {
	debugDraw.offset = b2Vec2(screenX * 2.0f / ScreenWidth - 1.0f, screenY * 2.0f / ScreenHeight - 1.0f);
	
	b2AABB aabb;
	aabb.lowerBound = b2Vec2(-screenX / drawScale, -screenY / drawScale);
	aabb.upperBound = b2Vec2((-screenX + ScreenWidth) / drawScale, (-screenY + ScreenHeight) / drawScale);
	
	world->DrawDebugDataInAABB(aabb);
}
