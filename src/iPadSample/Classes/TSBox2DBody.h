/*
 *  TSBox2DBody.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 1/8/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

#include "TSBox2D.h"
#include "TSSprite.h"
#include <tr1/unordered_map>

class TSBox2DBody {
public:
	static const int Solid = 0;
	static const int OneSided = 1;
	static const int Empty = 2;
	
	std::string id;
	TSBox2D* box2D;
	b2Body* body;
	TSSprite* sprite;
	int behavior;
	int ropeBehavior;
	bool onewayReversed;
	std::tr1::unordered_map<b2Contact*, int> behaviorForContact;
	
	TSBox2DBody(TSBox2D* box2D, b2Body* body, std::string sequencePath, int behavior, int ropeBehavior);
	TSBox2DBody* getUserDataA(b2Contact* contact);
	TSBox2DBody* getUserDataB(b2Contact* contact);
	void render(/* destination:BitmapData, */ int offsetX, int offsetY, float timeStep, float alpha, bool isOffScreen, TSMatrix* matrix = NULL);
	void update(float timeStep, bool isOffScreen = false);
	void CreateFixtures(std::vector<b2Shape*> shapes, float friction, float restitution);
	void createFixture(b2Shape* shape, float friction, float restitution);
	void initActiveBehavior(b2Contact* contact);
	void HandleBeginContact(b2Contact* contact);
	void BeginContact(b2Contact* contact);
	void HandleEndContact(b2Contact* contact);
	void EndContact(b2Contact* contact);
	void PreSolve(b2Contact* contact, b2Manifold* oldManifold);
	void PostSolve(b2Contact* contact, b2ContactImpulse* impulse);
	bool isSolidForRope(b2Vec2 normal);
};
