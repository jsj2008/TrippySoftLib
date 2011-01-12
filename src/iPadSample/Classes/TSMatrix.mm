/*
 *  TSMatrix.mm
 *  iPadSample
 *
 *  Created by Timothy Kerchmar on 12/12/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#include "TSMatrix.h"

TSMatrix::TSMatrix(float a, float b, float c, float d, float tx, float ty) {
	this->a = a;
	this->b = b;
	this->c = c;
	this->d = d;
	this->tx = tx;
	this->ty = ty;
}

TSMatrix::~TSMatrix() {
}

void TSMatrix::translate(float dx, float dy) {
	tx += dx;
	ty += dy;
}

void TSMatrix::rotate(float angle) {
	float sine = sin(angle);
	float cosine = cos(angle);
	float oldA = a;
	float oldB = b;
	float oldC = c;
	float oldD = d;
	float oldTx = tx;
	float oldTy = ty;
	
	a = oldA * cosine - oldB * sine;
	b = oldA * sine + oldB * cosine;
	c = oldC * cosine - oldD * sine;
	d = oldC * sine + oldD * cosine;
	tx = oldTx * cosine - oldTy * sine;
	ty = oldTx * sine + oldTy * cosine;
}

void TSMatrix::concat(TSMatrix* m) {
	float oldA = a;
	float oldB = b;
	float oldC = c;
	float oldD = d;
	float oldTx = tx;
	float oldTy = ty;
	
	a = oldA * m->a + oldB * m->c;
	b = oldA * m->b + oldB * m->d;
	c = oldC * m->a + oldD * m->c;
	d = oldC * m->b + oldD * m->d;
	tx = oldTx * m->a + oldTy * m->c + m->tx;
	ty = oldTx * m->b + oldTy * m->d + m->ty;
}

b2Vec2 TSMatrix::transformPoint(b2Vec2 point) {
	return b2Vec2(point.x * a + point.y * c + tx,
				  point.x * b + point.y * d + ty);
}
