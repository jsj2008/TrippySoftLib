/*
 *  selection.cpp
 *  OptimizeTilemap
 *
 *  Created by Timothy Kerchmar on 11/2/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#include "selection.h"
#include "image.h"

// in memcmp sort by result.
bool is_identical(Selection* selection1, Selection* selection2) {
	if(selection1->crc != selection2->crc) return false;
	if(selection1->width != selection2->width) return false;
	if(selection1->height != selection2->height) return false;
	
	int h = selection1->height;
	int w = selection1->width;
	
	for(int y = 0; y < h; y++)
		if(memcmp(&selection1->source->row_pointers[selection1->y + y][selection1->x * 4],
				  &selection2->source->row_pointers[selection2->y + y][selection2->x * 4],
				  w * 4) != 0) return false;
	
	return true;
}


void select_rect(Image *image, int x, int y, int width, int height, Selection *selection) {
	if(image->width < x + width) width = image->width - x;
	if(image->height < y + height) height = image->height - y;
	
	selection->source = image;
	selection->x = x;
	selection->y = y;
	selection->width = width;
	selection->height = height;
	
	selection->crc = 0;
	
	for (int y2 = 0; y2 < height; y2++) {
		png_byte* ptr = &image->row_pointers[y + y2][x * 4];
		
		for (int x2 = 0; x2 < width; x2++) {
			if(ptr[3] == 0) ptr[0] = ptr[1] = ptr[2] = 0;
			
			selection->crc += *((int *)ptr) * x2 * y2;
			
			ptr += 4;
		}
	}
}
