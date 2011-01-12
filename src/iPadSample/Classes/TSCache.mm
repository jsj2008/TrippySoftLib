/*
 *  TSCache.mm
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 1/8/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

#include "TSCache.h"
#include "stdaddtions.h"

using namespace std;

tr1::unordered_map<string, TSSequence*> TSCache::cache;

TSSequence* TSCache::getSequence(string resourcePath) {
	TSSequence* cachedSequence = cache[resourcePath];
	
	if(!cachedSequence) {
		cachedSequence = new TSSequence((char *)resourcePath.c_str());
		cache[resourcePath] = cachedSequence;
	}
	
	return cachedSequence;
}
