/*
 *  image.h
 *  OptimizeTilemap
 *
 *  Created by Timothy Kerchmar on 11/2/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#define PNG_DEBUG 3
#include <png.h>

struct Image {
	int width, height;
	png_byte color_type;
	png_byte bit_depth;
	png_bytep *row_pointers;
};

Image* read_png_file(const char* file_name);
void write_png_file(const char* file_name, Image* image);
void release_image(Image *image);
