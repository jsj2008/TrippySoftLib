/*
 *  TSBox2DBody.mm
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 1/8/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

#include <Box2D/Box2D.h>

#include "TSBox2DBody.h"
#include "Game.h"

using namespace std;

TSBox2DBody* TSBox2DBody::getUserDataA(b2Contact* contact) {
	return (TSBox2DBody *)contact->GetFixtureA()->GetBody()->GetUserData();
}

TSBox2DBody* TSBox2DBody::getUserDataB(b2Contact* contact) {
	return (TSBox2DBody *)contact->GetFixtureB()->GetBody()->GetUserData();
}

TSBox2DBody::TSBox2DBody(TSBox2D* box2D, b2Body* body, string sequencePath, int behavior, int ropeBehavior) {
	this->box2D = box2D;
	this->body = body;
	sprite = new TSSprite(sequencePath);
	this->behavior = behavior;
	this->ropeBehavior = ropeBehavior;
}
		
void TSBox2DBody::render(/* destination:BitmapData, */ int offsetX, int offsetY, float timeStep, float alpha, bool isOffScreen, TSMatrix* matrix) {
	// by default, do not render when offscreen. 
	// subclasses can either modify this behavior directly or just lie
	if(isOffScreen) return;
	
	// normalize roatation $$$
//	if (body->GetAngle() < 0.0f) {
//		body->m_sweep.a = body->GetAngle() + M_PI * 2.0f;
//	} else if (body->GetAngle() >= M_PI * 2.0f) {
//		body->m_sweep.a = body->GetAngle() - M_PI * 2.0f;
//	}
	
	sprite->render(//destination, 
				  timeStep,
				  body->GetPosition().x * box2D->drawScale + offsetX,
				  body->GetPosition().y * box2D->drawScale + offsetY,
				  body->GetAngle(),
				  alpha,
				  matrix);
}

void TSBox2DBody::update(float timeStep, bool isOffScreen) {
	if(body == NULL || body->GetType() != b2_dynamicBody) return;
	
	body->SetLinearVelocity(body->GetLinearVelocity() + timeStep * box2D->gravity);
	
	//trace("applying gravity to " + id + " with timestep " + step.dt);
	//var pos:b2Vec2 = body.GetPosition();
	//TS.log("    update was attempted on \"" + id + "\" at " + pos + " with timestep " + timeStep + " caller says isOffScreen = " + isOffScreen);
}

void TSBox2DBody::initActiveBehavior(b2Contact* contact) {
	int activeBehavior = behaviorForContact[contact];
//	if(activeBehavior == NULL /* should be behaviorForContact.hasKey contact $$$ */) {
//		activeBehavior = Solid;
//		
//		if(behavior == OneSided) {
//			// get contact normal, flipped correctly for our math
//			var contactNormal = contact.GetManifold().m_localPlaneNormal.Copy();
//			if(!contact.GetFixtureA().GetUserData() == this)
//				contactNormal.Multiply(-1);
//			
//			var enabled:Boolean = contactNormal.y < 0.0;
//			if(onewayReversed) enabled = !enabled;
//			activeBehavior = enabled ? Solid : Empty;
//		}
//		else if(behavior == Empty) {
//			activeBehavior = Empty;
//		}
//		
//		behaviorForContact[contact] = activeBehavior;
//	}
	
	contact->SetEnabled(activeBehavior == Solid);
}
		
void TSBox2DBody::HandleBeginContact(b2Contact* contact) {
}
		
void TSBox2DBody::BeginContact(b2Contact* contact) {
	TSBox2DBody* bA = getUserDataA(contact);
	TSBox2DBody* bB = getUserDataA(contact);
	
	if(bA) bA->HandleBeginContact(contact);
	if(bB) bB->HandleBeginContact(contact);

	int behaviorA = bA ? bA->behavior : Solid;
	int behaviorB = bB ? bB->behavior : Solid;
	
	if(contact->GetFixtureA()->GetBody() != Game::box2D->groundBody && contact->GetFixtureB()->GetBody() != Game::box2D->groundBody && (behaviorA != Solid || behaviorB != Solid)) {
		behaviorForContact[contact] = Empty;
		contact->SetEnabled(false);
	} else {
		behaviorForContact[contact] = Solid;
		contact->SetEnabled(true);
	}
}

void TSBox2DBody::HandleEndContact(b2Contact* contact) {
}

void TSBox2DBody::EndContact(b2Contact* contact) {
	TSBox2DBody* bA = getUserDataA(contact);
	TSBox2DBody* bB = getUserDataA(contact);
			
	if(bA) bA->HandleEndContact(contact);
	if(bB) bB->HandleEndContact(contact);
	
	// $$$ remove key!
	//behaviorForContact[contact];
}

void TSBox2DBody::PreSolve(b2Contact* contact, b2Manifold* oldManifold) {
	contact->SetEnabled(behaviorForContact[contact] == Solid);
}
		
void TSBox2DBody::PostSolve(b2Contact* contact, b2ContactImpulse* impulse) {
}
		
bool TSBox2DBody::isSolidForRope(b2Vec2 normal) {
	switch(ropeBehavior) {
		case Solid: 
			return true;
		case Empty: 
			return false;
		default:
			if(onewayReversed) return normal.y >= 0.0;
			return normal.y < 0.0;
	}
}

void TSBox2DBody::CreateFixtures(vector<b2Shape*> shapes, float friction, float restitution) {
	for(int i = 0; i < shapes.size(); i++) {
		b2Shape* shape = shapes[i];
		createFixture(shape, friction, restitution);
	}
}

void TSBox2DBody::createFixture(b2Shape* shape, float friction, float restitution) {
	b2Fixture* fixture = body->CreateFixture(shape, body->GetType() == b2_staticBody ? 0.0f : 1.0f);
	fixture->SetFriction(friction);
	fixture->SetRestitution(restitution);
}
