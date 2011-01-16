/*
 *  Game.h
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/14/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#include "TSTilemap.h"
#include "TSBox2D.h"
#include "TSBox2DSVG.h"

const int ScreenWidth = 1024;
const int ScreenHeight = 768;

class Game {
public:
	static Game* instance;
	static Game* getInstance();
	
	Game();
	~Game();
	void update();
	
	TSTilemap* tilemap;
	static TSBox2D* box2D;
	TSBox2DSVG* physicsSVG;
	
	b2Vec2 amountDragged;
	b2Vec2 dragSpeed;
	TiXmlDocument settings;
};