/*
 *  TSTilemap.cpp
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/12/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

using namespace std;

#include "TSTilemap.h"
#include "tinyxml.h"
#include "tilemap.h"
#include "Game.h"
#include <string>

TSTilemap::TSTilemap(NSString* tilemapPath) {
	// LOAD TILEMAP XML
	NSString* path = [[NSBundle mainBundle] pathForResource:tilemapPath ofType:@"xml"];
	TiXmlDocument sourceXML = TiXmlDocument([path cStringUsingEncoding:1]);
	bool xmlLoaded = sourceXML.LoadFile();
	if(!xmlLoaded) {
		NSLog(@"couldn't load or parse tilemap xml");
		return;
	}
	TileMap tilemap = tilemapFromXML(&sourceXML);
	tileWidth = tilemap.tileWidth;
	tileHeight = tilemap.tileHeight;
	outputTilesAcross = ScreenWidth / tileWidth;
	outputTilesDown	= ScreenHeight / tileHeight;
	totalWidth = tilemap.totalWidth;
	totalHeight = tilemap.totalHeight;
	
	// CREATE ALL POSSIBLE TILES THAT COULD EXIST
	vector<TSTile> allTiles;
	for (TiXmlNode* child = sourceXML.FirstChild()->FirstChild(); child != 0; child = child->NextSibling()) {
		TiXmlElement* element = child->ToElement();
		
		if(0 == strcmp(element->Value(), "atlas")) {
			// LOAD ATLAS
			string atlasFilename(element->GetText());
			TSSequence* atlas =	new TSSequence((char *)atlasFilename.c_str());
			atlases.push_back(atlas);
			
			// CREATE ALL TILES THAT COULD EXIST IN CURRENT ATLAS
			int atlasTilesAcross = atlas->width / tileWidth;
			int atlasTilesDown = atlas->height / tileHeight;
			
			for(int tileY = 0; tileY < atlasTilesDown; tileY++) {
				for(int tileX = 0; tileX < atlasTilesAcross; tileX++) {
					TSTile tile;
					tile.source = atlas;
					tile.sourceRect = TSRect((float)(tileX * tileWidth) / atlas->width, 
											 (float)(tileY * tileHeight) / atlas->height, 
											 (float)((tileX + 1) * tileWidth) / atlas->width, 
											 (float)((tileY + 1) * tileHeight) / atlas->height);
					allTiles.push_back(tile);
				}
			}
			
			//break; // $$$ memory test
		}
	}
	
	// CREATE 2D ARRAY OF TILES
	for(int tileY = 0; tileY < tilemap.tilemap.size(); tileY++) {
		vector<TSTile> row;
		
		for(int tileX = 0; tileX < tilemap.tilemap[0].size(); tileX++)
			row.push_back(//allTiles[0]);
						  allTiles[tilemap.tilemap[tileY][tileX]]);
		
		tiles.push_back(row);
	}
	
	originalImageTilesAcross = tiles[0].size();
	originalImageTilesDown = tiles.size();
}

TSTilemap::~TSTilemap() {
	for(int i = 0; i < atlases.size(); i++)
		delete atlases[i];
	
	atlases.clear();
	tiles.clear();
}

void TSTilemap::render(int x, int y) {
	// if the entire tilemap original image is outside screen bounds, don't draw
	if(x >= ScreenWidth  || x <= -totalWidth) return;
	if(y >= ScreenHeight || y <= -totalHeight) return;
	
	int screenStartX = x;
	int screenStartY = y;
	
	// when x < 0 (which should usually be true), we want to be
	// less than 1 tile's width from left side of screen to start drawing
	// same logic for y
	if(x < 0) screenStartX = -(-x % tileWidth);
	if(y < 0) screenStartY = -(-y % tileHeight);
	
	int tileStartX = -x / tileWidth;
	int tileY = -y / tileHeight;
	for(y = screenStartY; y < ScreenHeight; y += tileHeight) {
		if(tileY >= originalImageTilesDown) return;
		
		int tileX = tileStartX;
		
		for(x = screenStartX; x < ScreenWidth; x += tileWidth) {
			if(tileX >= originalImageTilesAcross) break;
			
			TSTile &tile = tiles[tileY][tileX];
			
			TSRect destinationRect((float)(x + x) / ScreenWidth - 1.0f,
								   (float)(y + y) / ScreenHeight - 1.0f,
								   (float)(x + x + tileWidth + tileWidth) / ScreenWidth - 1.0f,
								   (float)(y + y + tileHeight + tileHeight) / ScreenHeight - 1.0f);
			
			tile.source->render(&tile.sourceRect, &destinationRect, 0, 0xFFFFFFFF, NULL);
			
			tileX++;
		}
		
		tileY++;
	}
}
