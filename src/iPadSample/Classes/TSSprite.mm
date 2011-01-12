/*
 *  TSSprite.mm
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 1/8/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

#include "TSSprite.h"
#include "TSCache.h"

using namespace std;

TSSprite::TSSprite(string fileName, int x, int y, float r) {
	sequence = TSCache::getSequence(fileName);
	
	this->x = x;
	this->y = y;
	this->r = r;
	
	this->currentFrame = 0.0f;
}

void TSSprite::render(float timeDelta, int x, int y, float rotation, float alpha, TSMatrix* matrix) {
	currentFrame += timeDelta * 60.0f;
			
//	if(currentFrame >= sequence.frames.length && frameActions[sequence.frames.length - 1] != null) {
//		var frameCallback:Function = frameActions[sequence.frames.length - 1];
//		frameCallback();
//		return;
//	}
	
	currentFrame = fmod(currentFrame, sequence->frames.size());
	
	sequence->render(/*destination,*/ x + this->x, y + this->y, rotation + this->r, int(currentFrame), alpha, matrix);
}
		
//		public function setFrameAction(frame:int, f:Function) {
//			if(frame < 0) frameActions[sequence.frames.length + frame] = f;
//			else frameActions[frame] = f;
//		}
