/*
 *  PolyDecompBayazit
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 1/8/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

#include <algorithm>
#include "PolyDecompBayazit.h"

using namespace std;

int PolyDecompBayazit::polyID = 0;

float PolyDecompBayazit::area(b2Vec2 &a, b2Vec2 &b, b2Vec2 &c) {
	return (((b.x - a.x)*(c.y - a.y))-((c.x - a.x)*(b.y - a.y)));
}
		
bool PolyDecompBayazit::right(b2Vec2 &a, b2Vec2 &b, b2Vec2 &c) {
	return area(a, b, c) < 0;
}

bool PolyDecompBayazit::rightOn(b2Vec2 &a, b2Vec2 &b, b2Vec2 &c) {
	return area(a, b, c) <= 0;
}

bool PolyDecompBayazit::left(b2Vec2 &a, b2Vec2 &b, b2Vec2 &c) {
	return area(a, b, c) > 0;
}

bool PolyDecompBayazit::leftOn(b2Vec2 &a, b2Vec2 &b, b2Vec2 &c) {
	return area(a, b, c) >= 0;
}

float PolyDecompBayazit::sqdist(b2Vec2 &a, b2Vec2 &b) {
	float dx = b.x - a.x;
	float dy = b.y - a.y;
	return dx * dx + dy * dy;
}
		
b2Vec2* PolyDecompBayazit::getIntersection(b2Vec2 start1, b2Vec2 end1, b2Vec2 start2, b2Vec2 end2) {
	float a1 = end1.y - start1.y;
	float b1 = start1.x - end1.x;
	float c1 = a1 * start1.x + b1 * start1.y;
	float a2 = end2.y - start2.y;
	float b2 = start2.x - end2.x;
	float c2 = a2 * start2.x + b2 * start2.y;
	float det = a1 * b2 - a2*b1;
	
	if (fabs(det) > b2_epsilon) { // lines are not parallel
		lastIntersection = b2Vec2((b2 * c1 - b1 * c2) / det,  (a1 * c2 - a2 * c1) / det);
		return &lastIntersection;
	}
	return NULL;
}

void PolyDecompBayazit::combineColinearPoints() {
	// combine similar points
	vector<b2Vec2> combinedPoints;
	
	for(int i = 0; i < points.size(); i++) {
		b2Vec2 a = at(i - 1);
		b2Vec2 b = at(i);
		b2Vec2 c = at(i + 1);
		
		if(getIntersection(a, b, b, c) != NULL)
			combinedPoints.push_back(b);
	}
	
	points = combinedPoints;
}

PolyDecompBayazit::PolyDecompBayazit(std::vector<b2Vec2> points) {
	this->points = points;
	
	combineClosePoints();
	combineColinearPoints();
	combineClosePoints();
	
	if(this->points.size() > 2)
		makeCCW();
}

void PolyDecompBayazit::combineClosePoints() {
	vector<b2Vec2> combinedPoints;
	
	for(int i = 0; i < points.size(); i++) {
		b2Vec2 a = at(i);
		b2Vec2 b = at(i + 1);
		
		if(sqdist(a, b) > 0.035f) {
			combinedPoints.push_back(a);
		}
	}
	
	points = combinedPoints;
}

b2Vec2& PolyDecompBayazit::at(int i) {
	int s = points.size();
	return points[(i + s) % s];
}

bool PolyDecompBayazit::isReflex(int i) {
	return right(at(i - 1), at(i), at(i + 1));
}

PolyDecompBayazit* PolyDecompBayazit::polyFromRange(int lower, int upper) {
	if(lower < upper)
		return new PolyDecompBayazit(vector<b2Vec2>(points.begin() + lower, points.begin() + upper)); // $$$ off by 1 error for upper?
	else {
		vector<b2Vec2> slice(points.begin() + lower, points.end());
		slice.insert(slice.end(), points.begin(), points.begin() + upper);
		return new PolyDecompBayazit(slice);
	}
}

void PolyDecompBayazit::decompose(FoundPolygon callback, int recurseLevel) {
//	if(recurseLevel >= 100) {
//		TS.log("polygon recurse level = " + recurseLevel);
//	}
	
	if(points.size() < 3) return;
	
	for(int i = 0; i < points.size(); ++i) {
		if (isReflex(i)) {
			// Find closest two vertices in range from a reflex point (two the vertices are by going CW and CCW around polygon)
			// See first diagram on this page: http://mnbayazit.com/406/bayazit
			float upperDist = b2_maxFloat, lowerDist = b2_maxFloat;
			b2Vec2 upperIntersection, lowerIntersection;
			int upperIndex = 0, lowerIndex = 0;;
			
			for(int j = 0; j < points.size(); ++j) {
				if (left(at(i - 1), at(i), at(j)) && rightOn(at(i - 1), at(i), at(j - 1))) { // if line intersects with an edge
					b2Vec2* intersectionPoint = getIntersection(at(i - 1), at(i), at(j), at(j - 1)); // find the point of intersection
					if (right(at(i + 1), at(i), *intersectionPoint)) { // make sure it's inside the poly
						float distance = sqdist(at(i), *intersectionPoint);
						if (distance < lowerDist) { // keep only the closest intersection
							lowerDist = distance;
							lowerIntersection = *intersectionPoint;
							lowerIndex = j;
						}
					}
				}
				if (left(at(i + 1), at(i), at(j + 1)) && rightOn(at(i + 1), at(i), at(j))) {
					b2Vec2* intersectionPoint = getIntersection(at(i + 1), at(i), at(j), at(j + 1));
					if (left(at(i - 1), at(i), *intersectionPoint)) {
						float distance = sqdist(at(i), *intersectionPoint);
						if (distance < upperDist) {
							upperDist = distance;
							upperIntersection = *intersectionPoint;
							upperIndex = j;
						}
					}
				}
			}
			
			PolyDecompBayazit* lowerPoly = NULL;
			PolyDecompBayazit* upperPoly = NULL;
			
			// if there are no vertices to connect to, choose a point in the middle
			if (lowerIndex == (upperIndex + 1) % points.size()) {
				b2Vec2 steinerPoint((lowerIntersection.x + upperIntersection.x) * 0.5,
												   (lowerIntersection.y + upperIntersection.y) * 0.5);
				
				lowerPoly = polyFromRange(i, upperIndex);
				lowerPoly->points.push_back(steinerPoint);
				
				if (i < upperIndex)
					upperPoly = polyFromRange(lowerIndex, i);
				else
					upperPoly = polyFromRange(0, i);
				upperPoly->points.push_back(steinerPoint);
			} else {
				// connect to the closest point within the triangle
				
				// at(n) handles mod points.length, so increase upperIndex to make for loop easy
				if (lowerIndex >= upperIndex) upperIndex += points.size();
				
				// Find closest point in range
				int closestIndex = 0;
				float closestDist = b2_maxFloat;
				b2Vec2 closestVert;
				for (int j = lowerIndex; j <= upperIndex; ++j) {
					if (leftOn(at(i - 1), at(i), at(j)) && rightOn(at(i + 1), at(i), at(j))) {
						float distance = sqdist(at(i), at(j));
						if (distance < closestDist) {
							closestDist = distance;
							closestVert = at(j);
							closestIndex = j % points.size();
						}
					}
				}
				
				lowerPoly = polyFromRange(i, closestIndex);
				upperPoly = polyFromRange(closestIndex, i);
			}
			
			if(lowerPoly->points.size() == this->points.size() || upperPoly->points.size() == this->points.size()) {
				polyID++;
				/*for(j = 0; j < points.length; j++) {
				 Main.debugger.drawText("" + polyID + "-" + j + ": " + (at(j).x * 30).toPrecision(4) + ", " + (at(j).y * 30).toPrecision(4), new b2Vec2(at(j).x, at(j).y), 0xFFFFFF, true);
				 }*/
				
				//						if(lowerPoly.points.length > 0)
				//							lowerPoly.decompose(callback, recurseLevel);
				//						if(upperPoly.points.length > 0)
				//							upperPoly.decompose(callback, recurseLevel);
				
				return;
			}
			
			// solve smallest poly first
			if (lowerPoly->points.size() < upperPoly->points.size()) {
				lowerPoly->decompose(callback, recurseLevel + 1);
				upperPoly->decompose(callback, recurseLevel + 1);
			} else {
				upperPoly->decompose(callback, recurseLevel + 1);
				lowerPoly->decompose(callback, recurseLevel + 1);
			}
			return;
		}
	}
	
	if(points.size() >= 3) callback(this);
}

void PolyDecompBayazit::makeCCW() {
	int br = 0;
	
	// find bottom right point
	for (int i = 1; i < points.size(); ++i) {
		if (at(i).y < at(br).y || (at(i).y == at(br).y && at(i).x > at(br).x)) {
			br = i;
		}
	}
	
	// reverse poly if clockwise
	if (!left(at(br - 1), at(br), at(br + 1))) {
		std::reverse(points.begin(), points.end());
	}
}
