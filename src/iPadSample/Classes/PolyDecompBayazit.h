/*
 *  PolyDecompBayazit.h
 *  RopeBurnXCode
 *
 *  Created by Timothy Kerchmar on 1/8/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

#ifndef _POLYDECOMPBAYAZIT_H
#define _POLYDECOMPBAYAZIT_H

#include <Box2D/Box2D.h>
#include <vector>

typedef float TSFloat;

class PolyDecompBayazit;
typedef void(*FoundPolygon)(PolyDecompBayazit*);

class PolyDecompBayazit {
public:
	PolyDecompBayazit(std::vector<b2Vec2> points, bool repairPoints = true);
	TSFloat area(b2Vec2 &a, b2Vec2 &b, b2Vec2 &c);
	bool right(b2Vec2 &a, b2Vec2 &b, b2Vec2 &c);
	bool rightOn(b2Vec2 &a, b2Vec2 &b, b2Vec2 &c);
	bool left(b2Vec2 &a, b2Vec2 &b, b2Vec2 &c);
	bool leftOn(b2Vec2 &a, b2Vec2 &b, b2Vec2 &c);
	TSFloat sqdist(b2Vec2 &a, b2Vec2 &b);
	b2Vec2* getIntersection(b2Vec2 start1, b2Vec2 end1, b2Vec2 start2, b2Vec2 end2);
	b2Vec2 lastIntersection;
	std::vector<b2Vec2> points;
	void combineColinearPoints();
	static int polyID;
	b2Vec2& at(int i);
	bool isReflex(int i);
	PolyDecompBayazit* polyFromRange(int lower, int upper);
	void combineClosePoints();
	void makeCCW();
	void decompose(FoundPolygon callback, int recurseLevel);
};

#endif