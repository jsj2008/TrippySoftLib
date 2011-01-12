/*
 *  TSBox2DSVG.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 1/7/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

#include "TSSVGDelegate.h"
#include "TSBox2D.h"
#include "TSGameObject.h"
#include "tinyxml.h"
#include <string>
#include <vector>
#include "PolyDecompBayazit.h"
#include "stdaddtions.h"

class TSBox2DSVG : public TSSVGDelegate {
public:
	TSBox2DSVG(NSString* svgPath, TSBox2D* box2D);
	
	virtual void beginPath(TiXmlElement* path);
	virtual void endPath();
	virtual void moveTo(float x, float y);
	virtual void lineTo(float x, float y);
	virtual void curveTo(float controlX, float controlY, float x, float y);
	virtual void drawRect(float x, float y, float width, float height);
	virtual void drawRoundRect(float x, float y, float z, float u, float v, float w);
	virtual void drawCircle(float x, float y, float radius);
	virtual void drawEllipse(float x, float y, float z, float w);
	
	TSBox2D* box2D;
	TSGameObject* gameObject;
	std::vector<TSGameObject*> gameObjects;
	TSMatrix* globalTransform;
	bool addAsPolygons;
	int polySetID;
	int polyID;
	std::vector<b2Vec2> polyPoints;
	b2Vec2 lastPointReceivedFromSVGParser;
	b2Vec2 extents;

	void parseDescription(std::tr1::unordered_map<std::string, std::string>& attributes, TiXmlElement* path);
	void parseSVG(TiXmlElement* svg, TSMatrix* groupTransform, std::tr1::unordered_map<std::string, std::string> &inheritedAttributes);
	void foundPolygon(PolyDecompBayazit* polygon);
	void flushShapes();
	b2Vec2 lerp(b2Vec2 &p0, b2Vec2 &p1, float amount);
	b2Vec2 convertPoint(float x, float y);
	void complete();
};