/*
 *  Game.mm
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/14/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

using namespace std;

#include "Game.h"

Game* Game::instance = NULL;
TSBox2D* Game::box2D = NULL;

Game* Game::getInstance() {
	if(!instance) instance = new Game();
	
	return instance;
}

Game::Game() {
	tilemap = new TSTilemap(@"level1-foreground-optimized-tilemap");
	box2D = new TSBox2D(b2Vec2(0.0f, 38.0f));
	physicsSVG = new TSBox2DSVG(@"level1-physics", box2D);
	physicsSVG->complete();
}

Game::~Game() {
	delete box2D;
	box2D = NULL;
	delete tilemap;
	tilemap = NULL;
}

void Game::update() {
	static float currentX = 0, currentY = 0;
	
	if(amountDragged.x != 0.0f || amountDragged.y != 0.0f)
		dragSpeed = amountDragged;
	
	currentX += dragSpeed.x;
	currentY += dragSpeed.y;
	
	dragSpeed *= 0.9f;
	
	amountDragged.SetZero();
	
	if(currentX > 0.0f) currentX = 0.0f;
	if(currentY > 0.0f) currentY = 0.0f;
	
//	if(currentX < (-tilemap->totalWidth + ScreenWidth)) {
//		currentX = -tilemap->totalWidth + ScreenWidth;
//		speedX = -speedX;
//	}
//	
//	if(currentY < (-tilemap->totalHeight + ScreenHeight)) {
//		currentY = -tilemap->totalHeight + ScreenHeight;
//		speedY = -speedY;
//	}
//	
//	if(currentX > 0) {
//		currentX = 0;
//		speedX = -speedX;
//	}
//	
//	if(currentY > 0) {
//		currentY = 0;
//		speedY = -speedY;
//	}
    
	tilemap->render(currentX, currentY);
	box2D->syncBodiesAndGraphics(currentX, currentY, 1.0f/30.0f);
}