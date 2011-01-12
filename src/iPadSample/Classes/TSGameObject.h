/*
 *  TSGameObject.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 1/8/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

#ifndef _TSGAMEOBJECT_H
#define _TSGAMEOBJECT_H

#include <string>
#include <tr1/unordered_map>
#include <vector>
#include <Box2D/Box2D.h>
#include "TSSprite.h"

class TSGameObject {
public:
	TSGameObject(std::tr1::unordered_map<std::string, std::string> &attributes);

	b2MassData* massOverride;
	TSSprite* animation;
	std::string id;
	static int totalBodies;
	std::vector<b2Shape*> shapes;

	void addPolygon(std::vector<b2Vec2> points, bool addAsPolygon = true);
	void addCircle(b2Vec2 center, float radius);
	void createFixture(b2Shape* shape);
	void complete();
		
	b2Body* body;
	float friction;
	float restitution;
};

#endif