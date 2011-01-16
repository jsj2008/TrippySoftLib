/*
 *  b2XML.mm
 *  RopeBurnXCode
 *
 *  Ported to C++ by Timothy Kerchmar on 1/14/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */
/*
 * Copyright (c) 2009 Adam Newgas http://www.boristhebrave.com
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#include "b2XML.h"
#include "stdaddtions.h"

using namespace std;

float b2XML::loadFloat(const char* attribute, float defacto) {
	if(!attribute || strlen(attribute) == 0) return defacto;
	string attributeStr = attribute;
	float returnVal = stringToFloat(attributeStr);
	if(isnan(returnVal)) return defacto;
	return returnVal;
}
		
float b2XML::loadAngle(const char* attribute, float defacto) {
	if(!attribute || strlen(attribute) == 0) return defacto;
	float conversion = 1.0f;
	string attCopy = attribute;
	
	if(attCopy[attCopy.size() - 1] == 'd') {
		replace(attCopy, "d", "");
		conversion = M_PI / 180.0f;
	}
	
	float returnVal = stringToFloat(attCopy);
	if(isnan(returnVal)) return defacto;
	return returnVal * conversion;
}

int b2XML::loadInt(const char* attribute, int defacto) {
	if(!attribute || strlen(attribute) == 0) return defacto;
	
	string attributeStr = attribute;
	int returnVal = stringToInt(attributeStr);
	//
	return returnVal;
}

bool b2XML::loadBool(const char* attribute, bool defacto) {
	if(!attribute || strlen(attribute) == 0) return defacto;
	
	return strcmp(attribute, "true") == 0;
}

string b2XML::loadString(const char* attribute, string defacto) {
	if(!attribute || strlen(attribute) == 0) return defacto;
	
	return attribute;
}

b2Vec2 b2XML::loadVec2(const char* attribute, b2Vec2 defacto) {
	if(!attribute || strlen(attribute) == 0) return defacto;
	
	string attributeStr = attribute;
	vector<string> parts = split(attributeStr, " ");
	
	if(parts.size() != 2) return defacto;
	
	float x = stringToFloat(parts[0]);
	float y = stringToFloat(parts[1]);
	
	if(isnan(x) || isnan(y)) return defacto;
	return b2Vec2(x, y);
}

b2FixtureDef b2XML::loadFixtureDef(TiXmlElement* xml, b2FixtureDef* base) {
	b2FixtureDef to;
	
	if (base) {
		to.density = base->density;
		to.filter = base->filter;
		to.friction = base->friction;
		to.isSensor = base->isSensor;
		to.restitution = base->restitution;
		to.userData = base->userData;
	}
	
	const char* densityValue = xml->Attribute("density");
	if (densityValue) {
		string density = densityValue; // create mutable copy
		std::transform(density.begin(),density.end(),density.begin(),::tolower); // convert to lowercase
		
		if(density != "" && density != "default") {
			to.density = stringToFloat(density);
		}
	}
	
	to.restitution = loadFloat(xml->Attribute("restitution"), to.restitution);
	to.friction = loadFloat(xml->Attribute("friction"), to.friction);
	to.isSensor = loadBool(xml->Attribute("isSensor"), to.isSensor);
	if(xml->Attribute("userData")) to.userData = (void*)xml->Attribute("userData");
	to.filter.categoryBits = loadInt(xml->Attribute("categoryBits"), to.filter.categoryBits);
	loadInt(xml->Attribute("maskBits"), to.filter.maskBits);
	to.filter.groupIndex = loadInt(xml->Attribute("groupIndex"), to.filter.groupIndex);
	return to;
}

b2Shape* b2XML::loadShape(TiXmlElement* shape) {
	
	if(shape->ValueStr() == "circle") {
		b2CircleShape* circle = new b2CircleShape();
		circle->m_radius = loadFloat(shape->Attribute("radius"), 0.0f);
		b2Vec2 localPosition(loadFloat(shape->Attribute("x"), 0.0f), loadFloat(shape->Attribute("y"), 0.0f));
		circle->m_p = loadVec2(shape->Attribute("localPosition"), localPosition);
		return circle;
	}
	else if(shape->ValueStr() == "polygon") {
		b2Vec2 vertices[b2_maxPolygonVertices];
		int vertexCount = 0;
		for(TiXmlNode* vertexNode = shape->FirstChild(); vertexNode != NULL; vertexNode = vertexNode->NextSibling()) {
			TiXmlElement* vertex = vertex->ToElement();
			if(vertex->ValueStr() == "vertex")
				vertices[vertexCount++] = b2Vec2(stringToFloat(vertex->Attribute("x")),
												 stringToFloat(vertex->Attribute("y")));
		}
		
		b2PolygonShape* polygon = new b2PolygonShape();
		polygon->Set(vertices, vertexCount);
		return polygon;
	}
	else if(shape->ValueStr() == "box") {
		float x, y, left, right, top, bottom, angle, width, height;
		/*bool loadedX =*/ (shape->QueryFloatAttribute("x", &x) == TIXML_SUCCESS);
		/*bool loadedY =*/ (shape->QueryFloatAttribute("y", &y) == TIXML_SUCCESS);
		bool loadedLeft = (shape->QueryFloatAttribute("left", &left) == TIXML_SUCCESS);
		bool loadedRight = (shape->QueryFloatAttribute("right", &right) == TIXML_SUCCESS);
		bool loadedTop = (shape->QueryFloatAttribute("top", &top) == TIXML_SUCCESS);
		bool loadedBottom = (shape->QueryFloatAttribute("bottom", &bottom) == TIXML_SUCCESS);
		bool loadedAngle = (shape->QueryFloatAttribute("angle", &angle) == TIXML_SUCCESS);
		bool loadedWidth = (shape->QueryFloatAttribute("width", &width) == TIXML_SUCCESS);
		bool loadedHeight = (shape->QueryFloatAttribute("height", &height) == TIXML_SUCCESS);
		
		//Alt format
		if(!loadedAngle) {
			if(loadedLeft && loadedRight)
			{
				x = (right + left) * 0.5f;
				width = right - left;
			}
			if (loadedLeft && loadedWidth)
			{
				x = left + width * 0.5f;
			}
			if (loadedRight && loadedWidth)
			{
				x = right - width * 0.5f;
			}
			if (loadedTop && loadedBottom)
			{
				y = (bottom + top) * 0.5f;
				height = bottom - top;
			}
			if (loadedTop && loadedHeight)
			{
				y = top + height / 2;
			}
			if (bottom && height)
			{
				y = bottom - height / 2;
			}
		}
		
		b2PolygonShape* polygon = new b2PolygonShape();
		polygon->SetAsBox(width * 0.5f, height * 0.5f, b2Vec2(x, y), angle);
		return polygon;
	}
	
	return NULL;
}
	
b2BodyDef b2XML::loadBodyDef(TiXmlElement* body, b2BodyDef* base) {
	b2BodyDef bodyDef;
	
	if (base)
	{
		bodyDef.allowSleep = base->allowSleep;
		bodyDef.angle = base->angle;
		bodyDef.angularDamping = base->angularDamping;
		bodyDef.fixedRotation = base->fixedRotation;
		bodyDef.bullet = base->bullet;
		bodyDef.awake = base->awake;
		bodyDef.linearDamping = base->linearDamping;
		bodyDef.position = base->position;
		bodyDef.userData = base->userData;
	}
	
	bodyDef.allowSleep = loadBool(body->Attribute("allowSleep"), bodyDef.allowSleep);
	bodyDef.angle = loadAngle(body->Attribute("angle"), bodyDef.angle);
	bodyDef.angularDamping = loadFloat(body->Attribute("angularDamping"), bodyDef.angularDamping);
	bodyDef.fixedRotation = loadBool(body->Attribute("fixedRotation"), bodyDef.fixedRotation);
	bodyDef.bullet = loadBool(body->Attribute("isBullet"), bodyDef.bullet);
	bodyDef.awake = loadBool(body->Attribute("awake"), bodyDef.awake);
	bodyDef.linearDamping = loadFloat(body->Attribute("linearDamping"), bodyDef.linearDamping);
	bodyDef.position.x = loadFloat(body->Attribute("x"), bodyDef.position.x);
	bodyDef.position.y = loadFloat(body->Attribute("y"), bodyDef.position.y);
	bodyDef.position = loadVec2(body->Attribute("position"), bodyDef.position);
//$$$	bodyDef.userData = (void *)loadString(body->Attribute("userData"), (const char *)bodyDef.userData);
	return bodyDef;
}

b2Body* b2XML::loadBody(TiXmlElement* xml, b2World* world, b2BodyDef* bodyDef, b2FixtureDef* fixtureDef) {
	b2BodyDef bd = loadBodyDef(xml, bodyDef);
//	if (!bd) return null;
	b2Body* body = world->CreateBody(&bd);
	
	for(TiXmlNode* node = xml->FirstChild(); node != NULL; node = node->NextSibling()) {
		TiXmlElement* el = el->ToElement();
		b2FixtureDef fd = loadFixtureDef(el, fixtureDef);
		
		if(0 == strcmp(el->Value(), "fixture")) {
			for(TiXmlNode* shapeNode = node->FirstChild(); shapeNode; shapeNode = shapeNode->NextSibling()) {
				b2Shape* shape = loadShape(shapeNode->ToElement());
				if(shape) {
					fd.shape = shape;
					fd.density = 1.0f;
					body->CreateFixture(&fd);
				}
			}
		}
		else {
			b2Shape* shape = loadShape(xml);
			if(shape) {
				fd.shape = shape;
				fd.density = 1.0f;
				body->CreateFixture(&fd);
			}
		}
	}

	return body;
}

void b2XML::assignJointDefFromXML(TiXmlElement* xml, b2JointDef* to, b2Body* bodyA, b2Body* bodyB, b2JointDef* base) {
	if (base)
	{
		to->userData = base->userData;
		to->bodyA = base->bodyA;
		to->bodyB = base->bodyB;
		to->collideConnected = base->collideConnected;
		
		if (base->type == e_gearJoint && to->type == e_gearJoint)
		{
			((b2GearJointDef*)to)->joint1 = ((b2GearJointDef*)base)->joint1;
			((b2GearJointDef*)to)->joint2 = ((b2GearJointDef*)base)->joint2;
		}
	}
	to->bodyA = bodyA;
	to->bodyB = bodyB;
	b2Vec2 localAnchorA = loadVec2(xml->Attribute("local-anchorA"), b2Vec2(FloatNAN, FloatNAN));
	b2Vec2 localAnchorB = loadVec2(xml->Attribute("local-anchorB"), b2Vec2(FloatNAN, FloatNAN));
	b2Vec2 worldAnchorA = loadVec2(xml->Attribute("world-anchorA"), b2Vec2(FloatNAN, FloatNAN));
	b2Vec2 worldAnchorB = loadVec2(xml->Attribute("world-anchorB"), b2Vec2(FloatNAN, FloatNAN));
	b2Vec2 worldAnchor  = loadVec2(xml->Attribute("world-anchor"), b2Vec2(FloatNAN, FloatNAN));
	if (isValid(worldAnchor))
		worldAnchorA = worldAnchorB = worldAnchor;
	if (isValid(worldAnchorA))
		localAnchorA = to->bodyA->GetLocalPoint(worldAnchorA);
	if (isValid(worldAnchorA))
		localAnchorA = to->bodyB->GetLocalPoint(worldAnchorB);
	if (!isValid(localAnchorA))
		localAnchorA.SetZero();
	if (!isValid(localAnchorB))
		localAnchorB.SetZero();
	
	if (to->type == e_distanceJoint)
	{
		((b2DistanceJointDef*)to)->localAnchorA = localAnchorA;
		((b2DistanceJointDef*)to)->localAnchorB = localAnchorB;
	}
	else if (to->type == e_prismaticJoint)
	{
		((b2PrismaticJointDef*)to)->localAnchorA = localAnchorA;
		((b2PrismaticJointDef*)to)->localAnchorB = localAnchorB;
	}
	else if (to->type == e_revoluteJoint)
	{
		((b2RevoluteJointDef*)to)->localAnchorA = localAnchorA;
		((b2RevoluteJointDef*)to)->localAnchorB = localAnchorB;
	}
	else if (to->type == e_pulleyJoint)
	{
		((b2PulleyJointDef*)to)->localAnchorA = localAnchorA;
		((b2PulleyJointDef*)to)->localAnchorB = localAnchorB;
	}
	
	to->collideConnected = loadBool(xml->Attribute("collideConnected"), to->collideConnected);
}
		
b2JointDef b2XML::loadJointDef(TiXmlElement* joint, tr1::unordered_map<string, void*> &resolver, b2JointDef* base) {
	//Determine the bodies involved.
	b2Body* bodyA;
	b2Body* bodyB;
	if (base && base->bodyA) bodyA = base->bodyA;
	if (base && base->bodyB) bodyB = base->bodyB;
	if (joint->Attribute("bodyA")) bodyA = (b2Body*)resolver[joint->Attribute("bodyA")];
	if (joint->Attribute("bodyB")) bodyB = (b2Body*)resolver[joint->Attribute("bodyB")];
	
	if(0 == strcmp(joint->Value(), "gear")) {
		b2GearJointDef gearDef;
		assignJointDefFromXML(joint, &gearDef, bodyA, bodyB, base);
		gearDef.collideConnected = true;
		gearDef.ratio = loadFloat(joint->Attribute("ratio"), 1.0f);
		gearDef.joint1 = (b2Joint*)resolver[joint->Attribute("joint1")];
		gearDef.joint2 = (b2Joint*)resolver[joint->Attribute("joint2")];
		return gearDef;
	}
	else if(0 == strcmp(joint->Value(), "prismatic")) {
		b2PrismaticJointDef prismaticDef;
		assignJointDefFromXML(joint, &prismaticDef, bodyA, bodyB, base);
		// Parse from joint
		// Motor stuff
		prismaticDef.motorSpeed = loadFloat(joint->Attribute("motorSpeed"), prismaticDef.motorSpeed);
		prismaticDef.maxMotorForce = loadFloat(joint->Attribute("maxMotorForce"), FLT_MAX);
		prismaticDef.enableMotor = loadBool(joint->Attribute("enableMotor"), joint->Attribute("motorSpeed") || joint->Attribute("maxMotorForce"));
		// Limit stuff
		prismaticDef.lowerTranslation = loadFloat(joint->Attribute("lower"), -FLT_MAX);
		prismaticDef.upperTranslation = loadFloat(joint->Attribute("upper"), FLT_MAX);
		prismaticDef.enableLimit = loadBool(joint->Attribute("enableLimit"), joint->Attribute("lower") || joint->Attribute("upper"));
		//Joint stuff
		prismaticDef.referenceAngle = loadFloat(joint->Attribute("referenceAngle"), bodyB->GetAngle() - bodyA->GetAngle());
		
		b2Vec2 worldAxis = loadVec2(joint->Attribute("world-axis"), b2Vec2(FloatNAN, FloatNAN));
		b2Vec2 localAxis = loadVec2(joint->Attribute("local-axis-a"), b2Vec2(FloatNAN, FloatNAN));
		if (isValid(worldAxis))
			localAxis = bodyA->GetLocalVector(worldAxis);
		localAxis.Normalize();
		prismaticDef.localAxis1 = localAxis;
		
		return prismaticDef;
	}
	else if(0 == strcmp(joint->Value(), "revolute")) {
		b2RevoluteJointDef revoluteDef;
		assignJointDefFromXML(joint, &revoluteDef, bodyA, bodyB, base);
		// Motor stuff
		revoluteDef.motorSpeed = loadFloat(joint->Attribute("motorSpeed"), revoluteDef.motorSpeed);
		revoluteDef.maxMotorTorque = loadFloat(joint->Attribute("maxMotorTorque"), FLT_MAX);
		revoluteDef.enableMotor = loadBool(joint->Attribute("enableMotor"), joint->Attribute("motorSpeed") || joint->Attribute("maxMotorTorque"));
		// Limit stuff
		revoluteDef.lowerAngle = loadFloat(joint->Attribute("lower"), -FLT_MAX);
		revoluteDef.upperAngle = loadFloat(joint->Attribute("upper"), FLT_MAX);
		revoluteDef.enableLimit = loadBool(joint->Attribute("enableLimit"), joint->Attribute("lower") || joint->Attribute("upper"));
		revoluteDef.referenceAngle = loadFloat(joint->Attribute("referenceAngle"), bodyB->GetAngle() - bodyA->GetAngle());
		return revoluteDef;
	}
	else if(0 == strcmp(joint->Value(), "distance")) {
		b2DistanceJointDef distanceDef;
		assignJointDefFromXML(joint, &distanceDef, bodyA, bodyB, base);
		distanceDef.dampingRatio = loadFloat(joint->Attribute("dampingRatio"), distanceDef.dampingRatio);
		distanceDef.frequencyHz = loadFloat(joint->Attribute("frequencyHz"), distanceDef.frequencyHz);
		if (joint->Attribute("length"))
		{
			distanceDef.length = loadFloat(joint->Attribute("length"), 0.0f);
		}
		else
		{
			distanceDef.length = (bodyA->GetWorldPoint(distanceDef.localAnchorA) - bodyB->GetWorldPoint(distanceDef.localAnchorB)).Length();
		}
		return distanceDef;
	}
	else if(0 == strcmp(joint->Value(), "pulley")) {
		b2PulleyJointDef pulleyDef;
		assignJointDefFromXML(joint, &pulleyDef, bodyA, bodyB, base);
		
		pulleyDef.ratio = loadFloat(joint->Attribute("ratio"), 1);
		pulleyDef.maxLengthA = loadFloat(joint->Attribute("maxLengthA"), pulleyDef.maxLengthA);
		pulleyDef.maxLengthB = loadFloat(joint->Attribute("maxLengthB"), pulleyDef.maxLengthB);
		pulleyDef.groundAnchorA = loadVec2(joint->Attribute("world-groundA"), pulleyDef.groundAnchorA);
		pulleyDef.groundAnchorB = loadVec2(joint->Attribute("world-groundB"), pulleyDef.groundAnchorB);
		b2Vec2 ground = loadVec2(joint->Attribute("world-ground"), b2Vec2(FloatNAN, FloatNAN));
		if (isValid(ground))
		{
			pulleyDef.groundAnchorA = ground;
			pulleyDef.groundAnchorB = ground;
		}
		if (joint->Attribute("lengthA"))
		{
			pulleyDef.lengthA = loadFloat(joint->Attribute("lengthA"), pulleyDef.lengthA);
		}
		else
		{
			pulleyDef.lengthA = (bodyA->GetWorldPoint(pulleyDef.localAnchorA) - pulleyDef.groundAnchorA).Length();
		}
		if (joint->Attribute("lengthB"))
		{
			pulleyDef.lengthB = loadFloat(joint->Attribute("lengthB"), pulleyDef.lengthB);
		}
		else
		{
			pulleyDef.lengthB = (bodyB->GetWorldPoint(pulleyDef.localAnchorB) - pulleyDef.groundAnchorB).Length();
		}
		return pulleyDef;
	}
	else if(0 == strcmp(joint->Value(), "mouse")) {
		b2MouseJointDef mouseDef;
		assignJointDefFromXML(joint, &mouseDef, bodyA, bodyB, base);
		mouseDef.dampingRatio = loadFloat(joint->Attribute("dampingRatio"), mouseDef.dampingRatio);
		mouseDef.frequencyHz = loadFloat(joint->Attribute("frequencyHz"), mouseDef.frequencyHz);
		mouseDef.maxForce = loadFloat(joint->Attribute("maxForce"), mouseDef.maxForce);
		mouseDef.target = loadVec2(joint->Attribute("target"), mouseDef.target);
		return mouseDef;
	}
	
	return b2JointDef();
}

void b2XML::loadWorld(TiXmlElement* xml, b2World* world, 
					  std::tr1::unordered_map<std::string, void*> &resolver, 
					  b2BodyDef* bodyDef, 
					  b2FixtureDef* fixtureDef, 
					  b2JointDef* jointDef) {
	
	for(TiXmlNode* node = xml->FirstChild(); node; node = node->NextSibling()) {
		TiXmlElement* element = node->ToElement();
		
		if(element->Value() == "body") {
			b2Body* body = loadBody(element, world, bodyDef, fixtureDef);
			if(element->Attribute("id")) resolver[element->Attribute("id")] = body;
		}
		else {
			b2JointDef jd = loadJointDef(element, resolver, jointDef);
			b2Joint* joint = world->CreateJoint(&jd);
			if(element->Attribute("id")) resolver[element->Attribute("id")] = joint;
		}
	}
}

///** Inverse of loadFloat */
//public static function saveFloat(xml:XMLList, value:Number):void
//{
//	xml[0] = value.toString();
//}
//
///** Inverse of loadFloat, omitting the attribute for the default value. */
//public static function saveFloat2(xml:XMLList, value:Number, defacto:Number = 0.0):void
//{
//	if (Math.abs(value-defacto) < 4 * Number.MIN_VALUE)
//		delete xml[0];
//	else 
//		xml[0] = value.toString();
//}
//
///** Inverse of loadBool. */
//public static function saveBool(xml:XMLList, value:Boolean):void
//{
//	xml[0] = value ? "true" : "false"
//}
//
///** Inverse of loadBool, omitting the attribute for the default value. */
//public static function saveBool2(xml:XMLList, value:Boolean, defacto:Boolean = false):void
//{
//	if (value == defacto)
//		delete xml[0]
//		else
//			xml[0] = value ? "true" : "false"
//			}
//
///** 
// * Inverse of loadVec2
// * @param defacto If provided, and value equals defacto, then don't write the attribute.
// */
//public static function saveVec2(xml:XMLList, value:b2Vec2, defacto:b2Vec2 = null):void
//{
//	if (defacto && (Math.abs(value.x - defacto.x) < 4 * Number.MIN_VALUE) && (Math.abs(value.y - defacto.y) < 4 * Number.MIN_VALUE))
//		delete xml[0]
//		else
//			xml[0] = value.x.toString() + " " + value.y.toString();
//}
//
///** 
// * Inverse of loadFixtureDef
// * @param base If provided, and then for each field of def, don't write the attribute if it matches base.
// */
//public static function saveFixtureDef(xml:XML, def:b2FixtureDef, base:b2FixtureDef = null):void
//{
//}
//
///** Inverse of loadShape */
//public static function saveShape(shape:b2Shape):XML
//{
//	switch(shape.GetType())
//	{
//		case b2Shape.e_circleShape:
//		{
//			var circle:b2CircleShape = shape as b2CircleShape;
//			var circleXML:XML = <circle/>
//			circleXML.@radius = circle.GetRadius();
//			saveVec2(circleXML.@localPosition, circle.GetLocalPosition());
//			return circleXML;
//		}
//		case b2Shape.e_polygonShape:
//		{
//			var poly:b2PolygonShape = shape as b2PolygonShape;
//			var boxArray:Array = b2Geometry.DetectBox(shape);
//			if (boxArray)
//			{
//				var boxXML:XML = <box/>
//				saveFloat2(boxXML.@x, boxArray[2].x);
//				saveFloat2(boxXML.@y, boxArray[2].y);
//				saveFloat(boxXML.@width, boxArray[0]*2);
//				saveFloat(boxXML.@height, boxArray[1]*2);
//				saveFloat2(boxXML.@angle, boxArray[3]);
//				return boxXML;
//			}else {
//				var polyXML:XML = <polygon/>
//				var vertices:Vector.<b2Vec2> = poly.GetVertices();
//				for (var i:int = 0; i < poly.GetVertexCount(); i++)
//				{
//					polyXML.appendChild(<vertex x={vertices[i].x} y={vertices[i].y}/>);
//				}
//				return polyXML;
//			}
//		}
//		default:
//			return null;
//	}
//}
//
///** Inverse of loadBodyDef */
//public static function saveBodyDef(body:XML, bodyDef:b2BodyDef, base:b2BodyDef = null):void
//{
//	if (!base)
//	{
//		saveBool(body.@allowSleep, bodyDef.allowSleep);
//		saveFloat(body.@angle, bodyDef.angle);
//		saveFloat(body.@angularDamping, bodyDef.angularDamping);
//		saveBool(body.@fixedRotation, bodyDef.fixedRotation);
//		saveBool(body.@bullet, bodyDef.bullet);
//		saveBool(body.@awake, bodyDef.awake);
//		saveFloat(body.@linearDamping, bodyDef.linearDamping);
//		saveFloat(body.@x, bodyDef.position.x);
//		saveFloat(body.@y, bodyDef.position.y);
//		if (bodyDef.userData)
//		{
//			body.@userData = String(bodyDef.userData);
//		}else {
//			delete body.@userData;
//		}
//	} else {
//		saveBool2(body.@allowSleep, bodyDef.allowSleep, base.allowSleep);
//		saveFloat2(body.@angle, bodyDef.angle, base.angle);
//		saveFloat2(body.@angularDamping, bodyDef.angularDamping, base.angularDamping);
//		saveBool2(body.@fixedRotation, bodyDef.fixedRotation, base.fixedRotation);
//		saveBool2(body.@bullet, bodyDef.bullet, base.bullet);
//		saveBool2(body.@awake, bodyDef.awake, base.awake);
//		saveFloat2(body.@linearDamping, bodyDef.linearDamping, base.linearDamping);
//		saveFloat2(body.@x, bodyDef.position.x, base.position.x);
//		saveFloat2(body.@y, bodyDef.position.y, base.position.y);
//		if (bodyDef.userData && bodyDef.userData != base.userData)
//		{
//			body.@userData = String(bodyDef.userData);
//		}else {
//			delete body.@userData;
//		}
//	}
//}
//
///**
// * Saves a world to XML.
// * This doesn't currently support joints.
// */
//public static function saveWorld(world:b2World, bodyDef:b2BodyDef = null, fixtureDef:b2FixtureDef = null, jointDef:b2JointDef = null):XML
//{
//	var xml:XML = <world/>;
//	var map:Dictionary/*b2Body,XML*/ = new Dictionary();
//	var i:int = 0;
//	for (var body:b2Body = world.GetBodyList(); body; body = body.GetNext())
//	{
//		var bXml:XML = <body id={"b"+i.toString()}/>;
//		map[body] = bXml;
//		saveBodyDef(bXml, body.GetDefinition(), bodyDef);
//		xml.appendChild(bXml);
//		i++;
//	}
//	// TODO:
//	for (var joint:b2Joint = world.GetJointList(); joint; joint = joint.GetNext())
//	{
//	}
//	return xml;
//}
