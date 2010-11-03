/*
 * Copyright 2002-2008 Guillaume Cottenceau.
 *
 * This software may be freely redistributed under the terms
 * of the X11 license.
 *
 */

using namespace std;

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include <iostream>
#include <fstream>
#include <tr1/unordered_map>
#include "tinyxml.h"
#include "image.h"
#include "selection.h"
#include "tilemap.h"

void abort_(const char * s, ...)
{
	va_list args;
	va_start(args, s);
	vfprintf(stderr, s, args);
	fprintf(stderr, "\n");
	va_end(args);
	abort();
}

vector<Image*> outputAtlases;
vector<TileMap> outputTilemaps;
Image* currentAtlas = NULL;
int currentAtlasX;
int currentAtlasY;

Image* createImage(int width, int height) {
	Image* image = (Image*)malloc(sizeof(Image));
	image->width = width;
	image->height = height;
	image->color_type = PNG_COLOR_TYPE_RGBA;
	image->bit_depth = 8;
	image->row_pointers = (png_bytep*) malloc(sizeof(png_bytep) * image->height);
	for (int y = 0; y < image->height; y++) {
		image->row_pointers[y] = (png_byte*) malloc(image->width * 4);
		memset(image->row_pointers[y], 0, image->width * 4);
	}
	
	return image;
}

void moveSelectionToOutputAtlases(Selection* selection, int atlasWidth, int atlasHeight) {
	if(currentAtlas == NULL) {
		currentAtlas = createImage(atlasWidth, atlasHeight);
		currentAtlasX = 0;
		currentAtlasY = 0;
		
		outputAtlases.push_back(currentAtlas);
	}
	
	for(int y = 0; y < selection->height; y++) {
		void* source = &selection->source->row_pointers[selection->y + y][selection->x * 4];
		
		int destX = currentAtlasX;
		int destY = currentAtlasY + y;
		
		void* dest = &(currentAtlas->row_pointers[destY][destX * 4]);
		
		int byteCount = selection->width * 4;
		
		memcpy(dest, source, byteCount);
	}
	
	selection->source = currentAtlas;
	selection->x = currentAtlasX;
	selection->y = currentAtlasY;
	
	currentAtlasX += selection->width;
	if(currentAtlasX >= atlasWidth) {
		currentAtlasX = 0;
		currentAtlasY += selection->height;
	}
	
	if(currentAtlasY >= atlasHeight) currentAtlas = NULL;
}

vector<Selection> outputTiles;
tr1::unordered_map<int, vector<Selection> > outputTilesByCRC;

TileMap tilemapFromAtlas(Image* image, int tileWidth, int tileHeight, int atlasWidth, int atlasHeight) {
	TileMap tileMap;

	// iterate over tile sized sections of original image
	for (int tileY = 0; tileY < image->height; tileY += tileHeight) {
		vector<int> row;
		
		for (int tileX = 0; tileX < image->width; tileX += tileWidth) {
			
			// GRAB NEW TILE
			Selection newTile;
			select_rect(image, tileX, tileY, tileWidth, tileHeight, &newTile);
			
			// DISCOVER IF TILE IS UNIQUE
			vector<Selection> &tilesWithSameCRC = outputTilesByCRC[newTile.crc];
			vector<Selection>::iterator it = tilesWithSameCRC.begin();
			bool isUnique = true;
			
			while (it != tilesWithSameCRC.end() ) {
				Selection currentTile = *it;
				if(is_identical(&currentTile, &newTile)) {
					isUnique = false;
					break;
				}
				
				it++;
			}
			
			// IF TILE IS UNIQUE, ADD TO IMAGE LIST
			if(isUnique) {
				moveSelectionToOutputAtlases(&newTile, atlasWidth, atlasHeight);
				
				newTile.index = outputTiles.size();
				outputTiles.push_back(newTile);
				tilesWithSameCRC.push_back(outputTiles[newTile.index]);
				
				row.push_back(newTile.index);
			}
			else {
				row.push_back((*it).index);
			}
		}

		const char *busyMarkers = "|/-\\";
		printf("\b%c", busyMarkers[(tileY / tileHeight) & 3]);
		fflush(stdout);
		
		tileMap.tilemap.push_back(row);
	}

	return tileMap;
}

int main(int argc, char **argv) {
	// PROCESS COMMAND LINE ARGUMENTS
	if (argc != 7)
		abort_("Usage: program_name <file_in> <tile_width> <tile_height> <max_atlas_width> <max_atlas_height> <output_prefix>");
	
	string inputTilemapPath = argv[1];
	int outputTileWidth = atoi(argv[2]);
	int outputTileHeight = atoi(argv[3]);
	int maxAtlasWidth = atoi(argv[4]);
	int maxAtlasHeight = atoi(argv[5]);
	string outputPrefix = argv[6];
	
	// FIND ROOT DIRECTORY
	vector<string> pathParts = split(inputTilemapPath, "/");
	string path;
	
	if(pathParts.size() == 1) {
		path = "./";
	}
	else {
		for(int pathPartIndex = 0; pathPartIndex < pathParts.size() - 1; pathPartIndex++) {
			path += pathParts[pathPartIndex] + "/";
		}
	}
	
	printf("path is %s\n", path.c_str());
	
	// PROCESS SOURCE TILEMAP
	TiXmlDocument sourceXML(inputTilemapPath.c_str());
	bool xmlLoaded = sourceXML.LoadFile();
	
	if(!xmlLoaded) {
		abort_("couldn't load or parse tilemap");
	}
	
	TileMap inputTilemap = tilemapFromXML(&sourceXML);
	
	// FIND UNIQUE TILES IN EACH INPUT ATLAS
	for (TiXmlNode* child = sourceXML.FirstChild()->FirstChild(); child != 0; child = child->NextSibling()) {
		TiXmlElement* element = child->ToElement();
		
		if(0 == strcmp(element->Value(), "atlas")) {
			// push atlas into some kind of 2d array
			string atlasFilename = path + element->GetText();
			
			Image* image = read_png_file(atlasFilename.c_str());
			printf("Processing atlas %s (%d, %d) ", atlasFilename.c_str(), image->width, image->height);
			
			size_t numberOfUniqeTiles = outputTiles.size();
			
			TileMap atlasTilemap = tilemapFromAtlas(image, outputTileWidth, outputTileHeight, maxAtlasWidth, maxAtlasHeight);
			
			printf("found %i unique tiles\n", outputTiles.size() - numberOfUniqeTiles);
			
			outputTilemaps.push_back(atlasTilemap);
			
			release_image(image);
		}
	}
	
	// write xml output
	char outputXmlName[256];
	sprintf(outputXmlName, "%s%s-tilemap.xml", path.c_str(), outputPrefix.c_str());

	ofstream xml;
	xml.open(outputXmlName);
	xml << "<tilemap";
	xml << " width=\"" << inputTilemap.totalWidth << "\"";
	xml << " height=\"" << inputTilemap.totalHeight << "\"";
	xml << " tileWidth=\"" << outputTileWidth << "\"";
	xml << " tileHeight=\"" << outputTileHeight << "\">\n";
	
	int outputTilesAcross = inputTilemap.totalWidth / outputTileWidth;
	if(inputTilemap.totalWidth % outputTileWidth != 0) outputTilesAcross++;
	
	int outputTilesDown = inputTilemap.totalHeight / outputTileHeight;
	if(inputTilemap.totalWidth % outputTileHeight != 0) outputTilesDown++;
	
	TileMap finalOutput;
	for(int y = 0; y < outputTilesDown; y++) {
		finalOutput.tilemap.push_back(vector<int>());
	}
	
	for(int y = 0; y < inputTilemap.tilemap.size(); y++) {
		for(int x = 0; x < inputTilemap.tilemap[0].size(); x++) {
			int atlasAsTileIndex = inputTilemap.tilemap[y][x];
			
			TileMap spliceMeIn = outputTilemaps[atlasAsTileIndex];
			
			for(int y2 = 0; y2 < spliceMeIn.tilemap.size(); y2++) {
				
				int row = y * spliceMeIn.tilemap.size() + y2;
				
				if(row < outputTilesDown) {
					for(int x2 = 0; x2 < spliceMeIn.tilemap[0].size(); x2++) {
						finalOutput.tilemap[row].push_back(spliceMeIn.tilemap[y2][x2]);
					}
				}
			}
		}
	}
									  
	for(int y3 = 0; y3 < finalOutput.tilemap.size(); y3++) {
		xml << "    <row>";
		write_xml_row(xml, finalOutput.tilemap[y3]);
		xml << "</row>\n";
	}
	
	// output atlases
	for(int z = 0; z < outputAtlases.size(); z++) {
		Image* outputAtlas = outputAtlases[z];
		
		
		char atlasFilename[1024];
		
		sprintf(atlasFilename, "%s-%d.png", outputPrefix.c_str(), z);
		
		printf("writing %s\n", (path + atlasFilename).c_str());
		
		write_png_file((path + atlasFilename).c_str(), outputAtlas);
		
		xml << "    <atlas width=\"" << outputAtlas->width << "\" height=\"" << outputAtlas->height << "\">" << atlasFilename << "</atlas>\n";
	}
	
	xml << "</tilemap>\n";
	xml.close();	
	
	return 0;
}