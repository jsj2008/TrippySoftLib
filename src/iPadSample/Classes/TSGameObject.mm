/*
 *  TSGameObject.mm
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 1/8/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

using namespace std;

#include "TSGameObject.h"
#include <Box2D/Box2D.h>
#include "TSBox2DBody.h"
#include "Game.h"
#include "b2XML.h"

int TSGameObject::totalBodies = 0;
int TSGameObject::totalFixtures = 0;

TSGameObject::TSGameObject(tr1::unordered_map<string, string> &attributes) {
	this->friction = 1.0f;
	this->restitution = 0.0f;
	this->massOverride = NULL;
	this->id = attributes["id"];
	this->isCoin = !attributes["scoreincrease"].empty();
	this->animation = NULL;
	
	body = Game::box2D->groundBody;
}

void TSGameObject::complete() {
	b2PolygonShape* polygonShape;
	b2CircleShape* circleShape;
	b2EdgeShape* edgeShape;
	
	b2Vec2 centroid(0.0f, 0.0f);
	for(int i = 0; i < shapes.size(); i++) {
		b2Shape* shape = shapes[i];
		
		switch(shape->GetType()) {
			case b2Shape::e_polygon:
				polygonShape = (b2PolygonShape *)shape;
				centroid += polygonShape->m_centroid;
				break;
			case b2Shape::e_circle:
				circleShape = (b2CircleShape *)shape;
				centroid += circleShape->m_p;
				break;
			case b2Shape::e_edge:
				edgeShape = (b2EdgeShape *)shape;
				centroid += 0.5f * (edgeShape->m_vertex1 + edgeShape->m_vertex2);
				break;
		}
	}
	
	centroid *= 1.0f / shapes.size();
	
	if(animation) {
		animation->x = centroid.x * Game::box2D->drawScale;
		animation->y = centroid.y * Game::box2D->drawScale;
	}
	
	if(!body) return;
	
//		if(isNaN(centroid.x) || isNaN(centroid.y)) {
//			TS.log("uh oh, found NaN");
//		}
	if(body != Game::box2D->groundBody) {
	
		body->SetTransform(centroid, 0.0f);
		body->SetAwake(false);
		
		for(int j = 0; j < shapes.size(); j++) {
			b2Shape* shape = shapes[j];
			
			switch(shape->GetType()) {
				case b2Shape::e_polygon:
					polygonShape = (b2PolygonShape *)shape;
					polygonShape->m_centroid -= body->GetPosition();
					break;
				case b2Shape::e_circle:
					circleShape = (b2CircleShape *)shape;
					circleShape->m_p -= body->GetPosition();
					break;
			}
		}
	}
	
	// could also put into overload of TSBox2DBody::CreateFixture
	if(isCoin) {
		for(TiXmlNode* node = Game::getInstance()->settings.FirstChild("frame")->FirstChild("defaultShapes")->FirstChild("coin")->FirstChild(); node; node = node->NextSibling()) {
			b2FixtureDef fixtureDef = b2XML::loadFixtureDef(node->ToElement());
			fixtureDef.shape = b2XML::loadShape(node->ToElement());
			
			if(fixtureDef.shape->m_type == b2Shape::e_circle) {
				((b2CircleShape*)fixtureDef.shape)->m_p += centroid;
			}
			
			fixtureDef.density = 1.0f;
			body->CreateFixture(&fixtureDef);
		}
	} 
	else if(body->GetUserData())
		((TSBox2DBody *)body->GetUserData())->CreateFixtures(shapes, friction, restitution);
	else
		for(int k = 0; k < shapes.size(); k++)
			createFixture(shapes[k]);
	
	if(body->GetType() != b2_staticBody) {
		//TS.log("created body at " + centroid.x + "," + centroid.y + " with graphic " + body.GetUserData().sprite.sequence.fileName);
		body->ResetMassData();
		
		if(massOverride) body->SetMassData(massOverride);
	}
	
	shapes.clear();
	
	totalBodies++;
}

void TSGameObject::createFixture(b2Shape* shape) {
	totalFixtures++;
	
	b2Fixture* fixture = body->CreateFixture(shape, body->GetType() == b2_staticBody ? 0.0f : 1.0f);
	fixture->SetFriction(friction);
	fixture->SetRestitution(restitution);
}

void TSGameObject::addPolygon(vector<b2Vec2> points, bool addAsPolygon) {
	if(addAsPolygon) {
		b2PolygonShape* shape = new b2PolygonShape();
		shape->Set(&points[0], points.size());
		shapes.push_back(shape);
	}
	else {
		points.push_back(points[0]);
		for(int i = 0; i < points.size() - 1; i++) {
			b2EdgeShape* shape = new b2EdgeShape();
			// $$$ there are extra fields in an edge shape
			// useful for smoothing collision
			shape->Set(points[i], points[i + 1]);
			shapes.push_back(shape);
		}
	}
}
		
void TSGameObject::addCircle(b2Vec2 center, float radius) {
	b2CircleShape* shape = new b2CircleShape();
	shape->m_radius = radius;
	shape->m_p = center;
	shapes.push_back(shape);
}
