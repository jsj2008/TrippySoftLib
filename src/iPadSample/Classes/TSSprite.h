/*
 *  TSSprite.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 1/8/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

#ifndef _TSSPRITE_H
#define _TSSPRITE_H

#include "TSSequence.h"
#include <string>

class TSSprite {
public:
	TSSprite(std::string fileName, int x = 0, int y = 0, float r = 0.0f);
	
	int x, y;
	float r;
	TSSequence* sequence;
	float currentFrame;
	
//	public var frameActions:Array = new Array();
	void render(float timeDelta, int x, int y, float rotation, float alpha, TSMatrix* matrix = NULL);
};

#endif