/*
 *  TSBox2DSVG.mm
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 1/7/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

using namespace std;

#include <algorithm>
#include "TSBox2DSVG.h"
#include "stdaddtions.h"
#include "MiniSVGWeb.h"

TSBox2DSVG::TSBox2DSVG(NSString* svgPath, TSBox2D* box2D) {
	this->box2D = box2D;
	
	// LOAD TILEMAP XML
	NSString* path = [[NSBundle mainBundle] pathForResource:svgPath ofType:@"svg"];
	TiXmlDocument doc = TiXmlDocument([path cStringUsingEncoding:1]);
	
	if(!doc.LoadFile()) {
		NSLog(@"could not load %@", path);
		return;
	}
	
	TiXmlElement* svg = doc.FirstChild("svg")->ToElement();
	svg->QueryFloatAttribute("width", &extents.x);
	svg->QueryFloatAttribute("height", &extents.y);
	
	tr1::unordered_map<string, string> rootHash;
	
	TSMatrix groupTransform;
	parseSVG(svg, &groupTransform, rootHash);
}

void TSBox2DSVG::parseDescription(tr1::unordered_map<string, string>& attributes, TiXmlElement* path) {
	TiXmlNode* descriptionNode = path->FirstChild("desc");
	
	if(!descriptionNode) return;
	
	TiXmlElement* descriptionElement = descriptionNode->ToElement();
	string description = descriptionElement->GetText();
	
//	replace(pairs, "\r");
	vector<string> pairs = split(description, "\n");
	
	for(int i = 0; i < pairs.size(); i++) {
		vector<string> keyAndValue = split(pairs[i], "=");
		
		std::transform(keyAndValue[0].begin(),keyAndValue[0].end(),keyAndValue[0].begin(),::tolower);
		attributes[keyAndValue[0]] = keyAndValue[1];
	}
}

void TSBox2DSVG::parseSVG(TiXmlElement* svg, TSMatrix* groupTransform, tr1::unordered_map<string, string> &inheritedAttributes) {
	
	for(TiXmlNode* pathNode = svg->FirstChild(); pathNode != NULL; pathNode = pathNode->NextSibling()) {
		
		//NSLog(@"parsing %s", pathNode->Value());
		
		TiXmlElement* path = pathNode->ToElement();
		
		if(path->ValueStr() == "g") {
			TSMatrix newGroupTransform;
			MiniSVGWeb::parseTransform((char*)path->Attribute("transform"), &newGroupTransform);
			newGroupTransform.concat(groupTransform);
			
			tr1::unordered_map<string, string> attributes = inheritedAttributes;
			parseDescription(attributes, path);
			parseSVG(path, &newGroupTransform, attributes);
		}
		else if(path->ValueStr() == "path") {
			tr1::unordered_map<string, string> attributes = inheritedAttributes;
			parseDescription(attributes, path);
			attributes["id"] = path->Attribute("id");
			
			gameObject = new TSGameObject(attributes);
			gameObjects.push_back(gameObject);
			addAsPolygons = gameObject->body != box2D->groundBody;
			
			TSMatrix pathTransform;
			MiniSVGWeb::parseTransform((char*)path->Attribute("transform"), &pathTransform);
			globalTransform = &pathTransform;
			globalTransform->concat(groupTransform);
			
			float rx, ry, cx, cy;
			if(path->QueryFloatAttribute("rx", &rx) == TIXML_SUCCESS && path->QueryFloatAttribute("ry", &ry) == TIXML_SUCCESS && fabs(rx - ry) < FLT_EPSILON) {
				path->QueryFloatAttribute("cx", &cx);
				path->QueryFloatAttribute("cy", &cy);
				drawCircle(cx, cy, rx);
			}
			else {
				MiniSVGWeb::parse(path, this);
			}
		}
		
		flushShapes();
//		if(gameObject != NULL && gameObject.shapes.length == 0) {
//			TS.log("created gameobject " + path.@id + " with no shapes");
//		}
	}
}

b2Vec2 TSBox2DSVG::convertPoint(float x, float y) {
	b2Vec2 p = globalTransform->transformPoint(b2Vec2(x, y));
	float ds = box2D->drawScale;
	return b2Vec2(p.x / ds, p.y / ds);
}
	
void TSBox2DSVG::moveTo(float x, float y) {
	lastPointReceivedFromSVGParser = convertPoint(x, y);

	//NSLog(@"svg parse output: move cursor to %g, %g", lastPointReceivedFromSVGParser.x, lastPointReceivedFromSVGParser.y);

	flushShapes();
}

b2Vec2 ComputeCentroid(const b2Vec2* vs, int32 count);

void TSBox2DSVG::flushShapes() {
	if(polyPoints.size() > 0) {
		PolyDecompBayazit* polygon = new PolyDecompBayazit(polyPoints);
		bool giveUpOnCreatingRequestedShape = false;
		
		if(polygon->points.size() < 2) {
			giveUpOnCreatingRequestedShape = true;
		}
		else {
			//if(gameObject.body == box2D->world->GetGroundBody())
			//	Main.terrainBitmap.addRawPolygon(polygon);
					
			/*if(addAsPolygons) 	polygon.decompose(foundPolygon);
			else*/ 				foundPolygon(polygon);
							
			// if nothing was generated, also draw circle
			if(polyID == 0) 
				giveUpOnCreatingRequestedShape = true;
		}
			
		if(giveUpOnCreatingRequestedShape) {
			b2Vec2 center = ComputeCentroid(&polyPoints[0], polyPoints.size());
			drawCircle(center.x, center.y, 1.0f);
		}
		
		polyPoints.clear();
		
		polySetID++;
		polyID=0;
	}
}

void TSBox2DSVG::lineTo(float x, float y) {
	b2Vec2 newPoint = convertPoint(x, y);
	
	//NSLog(@"svg parse output: line between - %g, %g", newPoint.x, newPoint.y);
		
	if (polyPoints.size() == 0) {
		polyPoints.push_back(lastPointReceivedFromSVGParser);
	}
	polyPoints.push_back(newPoint);
	
	lastPointReceivedFromSVGParser = newPoint;
}

void TSBox2DSVG::drawRect(float x, float y, float width, float height) {
	b2Vec2 dims = convertPoint(width * 0.5, height * 0.5);
	b2Vec2 origin = convertPoint(x, y);
	
	b2PolygonShape* shape = new b2PolygonShape();
	shape->SetAsBox(dims.x, dims.y, b2Vec2(origin.x + dims.x, origin.y + dims.y), 0.0f);
	
	box2D->groundBody->CreateFixture(shape, 1.0);
}

void TSBox2DSVG::drawCircle(float x, float y, float radius) {
	b2Vec2 origin = convertPoint(x, y);
	gameObject->addCircle(b2Vec2(origin.x, origin.y), radius / box2D->drawScale);
}
	
void TSBox2DSVG::drawRoundRect(float x, float y, float z, float u, float v, float w) {
}
	
void TSBox2DSVG::drawEllipse(float x, float y, float z, float w) {
}

void TSBox2DSVG::curveTo(float controlX, float controlY, float x, float y) {
	if (polyPoints.size() == 0) {
		polyPoints.push_back(lastPointReceivedFromSVGParser);
	}
	
	b2Vec2 p0 = lastPointReceivedFromSVGParser;
	b2Vec2 p1 = convertPoint(controlX, controlY);
	b2Vec2 p2 = convertPoint(x, y);
	
	float amount = 0.5f;
	b2Vec2 q0 = lerp(p0, p1, amount);
	b2Vec2 q1 = lerp(p1, p2, amount);
	b2Vec2 b = lerp(q0, q1, amount);
	
	b2Vec2 l = lerp(p0, p2, amount);
	
	// if point is 15 pixels away from where line is, then add point
	if((b.x - l.x) * (b.x - l.x) + (b.y - l.y) * (b.y - l.y) > 0.25f)
		polyPoints.push_back(b);
		
	polyPoints.push_back(p2);
	lastPointReceivedFromSVGParser = p2;
}

b2Vec2 TSBox2DSVG::lerp(b2Vec2 &p0, b2Vec2 &p1, float amount) {
	return b2Vec2(p0.x + (p1.x - p0.x) * amount, p0.y + (p1.y - p0.y) * amount);
}

void TSBox2DSVG::foundPolygon(PolyDecompBayazit* polygon) {
	polyID++;
	
	gameObject->addPolygon(polygon->points, addAsPolygons);
}
	
//	public var message:String;
//	public function getProgress():String {
//		return message;
//	}
//	
//	public var doneLoading:Boolean=false;
//	public function isReady():Boolean {
//		return doneLoading;
//	}
//	
//	public var extents:Point;
//	public function getExtents():Point {
//		return extents;
//	}
	

void TSBox2DSVG::beginPath(TiXmlElement* path) {
}
	
void TSBox2DSVG::endPath() {
	moveTo(0.0f, 0.0f);
}

void TSBox2DSVG::complete() {
	for(int i = 0; i < gameObjects.size(); i++) gameObjects[i]->complete();
	
	b2DynamicTree *tree = (b2DynamicTree *)&box2D->world->GetContactManager().m_broadPhase.m_tree;
	tree->Rebalance(10000);
	
	NSLog(@"full height is %i with 10,000 iterations", tree->ComputeHeight());
	NSLog(@"created %i bodies with %i fixtures", TSGameObject::totalBodies, TSGameObject::totalFixtures);
	
	gameObjects.clear();
}