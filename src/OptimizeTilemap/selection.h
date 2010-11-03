/*
 *  selection.h
 *  OptimizeTilemap
 *
 *  Created by Timothy Kerchmar on 11/2/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

struct Image;

struct Selection {
	Image* source;
	int x;
	int y;
	int width;
	int height;
	int crc;
	int index;
};

void select_rect(Image *image, int x, int y, int width, int height, Selection *selection);
bool is_identical(Selection* selection1, Selection* selection2);
