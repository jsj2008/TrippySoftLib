/*
 *  TSSVGDelegate.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 1/5/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

#ifndef _TSSVGDELEGATE_H
#define _TSSVGDELEGATE_H

#include "tinyxml.h"

class TSSVGDelegate {
public:
	virtual void beginPath(TiXmlElement* path) = 0;
	virtual void endPath() = 0;
	virtual void moveTo(float x, float y) = 0;
	virtual void lineTo(float x, float y) = 0;
	virtual void curveTo(float controlX, float controlY, float x, float y) = 0;
	virtual void drawRect(float x, float y, float width, float height) = 0;
	virtual void drawRoundRect(float x, float y, float z, float u, float v, float w) = 0;
	virtual void drawCircle(float x, float y, float radius) = 0;
	virtual void drawEllipse(float x, float y, float z, float w) = 0;
};

#endif