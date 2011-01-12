/*
 *  TSCache.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 1/8/11.
 *  Copyright 2011 The Night School, LLC. All rights reserved.
 *
 */

#include <tr1/unordered_map>
#include <string>
#include "TSSequence.h"

class TSCache {
public:
	static std::tr1::unordered_map<std::string, TSSequence*> cache;
	static TSSequence* getSequence(std::string resourcePath);
};