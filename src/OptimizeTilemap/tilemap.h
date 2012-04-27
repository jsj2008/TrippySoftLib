/*
 *  tilemap.h
 *  OptimizeTilemap
 *
 *  Created by Timothy Kerchmar on 11/3/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */
#include <vector>
#include <string>
#include "tinyxml.h"

struct TileMap {
	std::vector<std::vector<int> > tilemap;
	int totalWidth, totalHeight, tileWidth, tileHeight, highestIndex;
};

TileMap tilemapFromXML(TiXmlDocument* doc);
std::vector<std::string> split(std::string input, std::string splitOn);
void write_xml_row(std::ofstream &xml, std::vector<int> indices);
