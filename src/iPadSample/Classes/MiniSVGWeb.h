/*
 *  MiniSVGWeb.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 1/3/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

#include "TSMatrix.h"
#include "tinyxml.h"
#include "TSSVGDelegate.h"

#include <vector>
#include <Box2D/Box2D.h>

class SvgArc {
public:
	SvgArc(float x, float y, float startAngle, float arc, float radius, float yRadius, float xAxisRotation, float cx, float cy);
	float x, y, startAngle, arc, radius, yRadius, xAxisRotation, cx, cy;
};

class MiniSVGWeb {
public:
	static void parse(TiXmlElement* path, TSSVGDelegate* delegate);
	static TSMatrix* parseTransform(char* tran, TSMatrix* baseMatrix = NULL);
	static void draw(TSSVGDelegate* delegate, TiXmlElement* path);
	static vector<string> normalizeSVGData(TiXmlElement* path);
	static void generateGraphicsCommands(TiXmlElement* path);
	static void closePath();
	static void moveTo(float x, float y, bool isAbs);
	static void lineHorizontal(float x, bool isAbs);
	static void lineVertical(float y, bool isAbs);
	static void line(float x, float y, bool isAbs);
	static float ellipticalArc(float rx, float ry, float xAxisRotation, float largeArcFlag, float sweepFlag, float x, float y, bool isAbs);
	static void quadraticBezierSmooth(float x, float y, bool isAbs);
	static void quadraticBezier(float x1, float y1, float x, float y, bool isAbs);
	static void cubicBezierSmooth(float x2, float y2, float x, float y, bool isAbs);
	static void cubicBezier(float x1, float y1, float x2, float y2,
								 float x, float y, bool isAbs);
	static b2Vec2 getPointOnSegment(b2Vec2 P0, b2Vec2 P1, float ratio);
	static b2Vec2 getMiddle(b2Vec2 P0, b2Vec2 P1);
	static SvgArc computeSvgArc(float rx, float ry, float angle, 
								  bool largeArcFlag, bool sweepFlag,
								  float x, float y, float LastPointX, float LastPointY);
	static float degreesToRadians(float angle);
	static float radiansToDegrees(float angle);
	
	static vector<vector<string> > graphicsCommands;
	static float currentX;
	static float currentY;
	static float startX;
	static float startY;
	static float lastCurveControlX;
	static float lastCurveControlY;
};
