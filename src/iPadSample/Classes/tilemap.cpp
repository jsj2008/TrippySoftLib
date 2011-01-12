/*
 *  tilemap.cpp
 *  OptimizeTilemap
 *
 *  Created by Timothy Kerchmar on 11/3/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

using namespace std;

#include <iostream>
#include <fstream>
#include "tilemap.h"

#include "stdaddtions.h"

vector<int> parseRow(string rowText) {
	vector<int> row;
	vector<string> tuples = split(rowText, "),(");
	
	for(int tupleIndex = 0; tupleIndex < tuples.size(); tupleIndex++) {
		string tuple = tuples[tupleIndex];
		
		vector<string> tupleParts = split(tuple, "(");
		if(tupleParts.size() > 1) tuple = tupleParts[1];
		
		tupleParts = split(tuple, ")");
		if(tupleParts.size() > 1) tuple = tupleParts[0];
		
		tupleParts = split(tuple, ",");
		int tileIndex = atoi(tupleParts[0].c_str());
		int tileRun = atoi(tupleParts[1].c_str());
		
		while(tileRun != 0) {
			row.push_back(tileIndex);
			
			if(tileRun > 0) {
				tileIndex++;
				tileRun--;
			}
			else {
				tileRun++;
			}
		}
	}
	
	return row;
}

TileMap tilemapFromXML(TiXmlDocument* doc) {
	TileMap tilemap;
	
	// Get top level attributes for source tilemap
	TiXmlElement* tilemapElement = doc->FirstChild()->ToElement();
//	int totalWidth, totalHeight, inputTileWidth, inputTileHeight;
	assert(TIXML_SUCCESS == tilemapElement->QueryIntAttribute("width", &tilemap.totalWidth));
	assert(TIXML_SUCCESS == tilemapElement->QueryIntAttribute("height", &tilemap.totalHeight));
	assert(TIXML_SUCCESS == tilemapElement->QueryIntAttribute("tileWidth", &tilemap.tileWidth));
	assert(TIXML_SUCCESS == tilemapElement->QueryIntAttribute("tileHeight", &tilemap.tileHeight));
	
	tilemap.highestIndex = 0;
	
	// CREATE ORIGINAL TILEMAP (and find number of atlases)
	for (TiXmlNode* child = doc->FirstChild()->FirstChild(); child != 0; child = child->NextSibling()) {
		TiXmlElement* element = child->ToElement();
		
		if(0 == strcmp(element->Value(), "row")) {
			string rowText = element->GetText();
			vector<int> inputRow = parseRow(rowText);
			tilemap.tilemap.push_back(inputRow);
		}
		else if(0 == strcmp(element->Value(), "atlas")) {
			int atlasWidth, atlasHeight;
			
			assert(TIXML_SUCCESS == element->QueryIntAttribute("width", &atlasWidth));
			assert(TIXML_SUCCESS == element->QueryIntAttribute("height", &atlasHeight));
			
			tilemap.highestIndex += (atlasWidth / tilemap.tileWidth) * (atlasHeight / tilemap.tileHeight);
		}
	}
	
	return tilemap;
}

void write_xml_row(ofstream &xml, vector<int> indices) {
	for(int x = 0; x < indices.size(); x++) {
		
		xml << "(" << indices[x] << ",";
		
		int run = 1;
		for(int x2 = x + 1; x2 < indices.size(); x2++)
			if(indices[x2] == indices[x] + x2 - x)
				run++;
			else break;
		
		if(run == 1) {
			for(int x2 = x + 1; x2 < indices.size(); x2++)
				if(indices[x2] == indices[x])
					run++;
				else break;
			
			xml << -run << ")";
		}
		else xml << run << ")";
		
		x += run - 1;
		
		if(x < indices.size() - 1) xml << ",";
	}
}
