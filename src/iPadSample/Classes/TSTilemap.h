/*
 *  TSTilemap.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/12/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#ifndef _TSTILEMAP_H
#define _TSTILEMAP_H

#include <vector>
#include "TSSequence.h"

class TSTile {
public:
	TSSequence* source;
	TSRect sourceRect;
};

class TSTilemap {
public:
	TSTilemap(NSString* tilemapPath);
	~TSTilemap();

	void render(int x, int y);
	
	std::vector<TSSequence *> atlases;
	std::vector< std::vector<TSTile> > tiles;
	int tileWidth, tileHeight, totalWidth, totalHeight;
	int outputTilesAcross, outputTilesDown;
	int originalImageTilesAcross, originalImageTilesDown;
};

#endif