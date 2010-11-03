/*
 *  image.cpp
 *  OptimizeTilemap
 *
 *  Created by Timothy Kerchmar on 11/2/10.
 *  Copyright 2010 The Night School, LLC. All rights reserved.
 *
 */

#include "image.h"
#include <stdlib.h>

void abort_(const char * s, ...);

Image* read_png_file(const char* file_name)
{
	png_byte header[8];	// 8 is the maximum size that can be checked
	
	/* open file and test for it being a png */
	FILE *fp = fopen(file_name, "rb");
	if (!fp)
		abort_("[read_png_file] File %s could not be opened for reading", file_name);
	fread(header, 1, 8, fp);
	if (png_sig_cmp(header, 0, 8))
		abort_("[read_png_file] File %s is not recognized as a PNG file", file_name);
	
	
	/* initialize stuff */
	png_structp png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	
	if (!png_ptr)
		abort_("[read_png_file] png_create_read_struct failed");
	
	png_infop info_ptr = png_create_info_struct(png_ptr);
	if (!info_ptr)
		abort_("[read_png_file] png_create_info_struct failed");
	
	if (setjmp(png_jmpbuf(png_ptr)))
		abort_("[read_png_file] Error during init_io");
	
	png_init_io(png_ptr, fp);
	png_set_sig_bytes(png_ptr, 8);
	
	png_read_info(png_ptr, info_ptr);
	
	Image* image = (Image*)malloc(sizeof(Image));
	image->width = info_ptr->width;
	image->height = info_ptr->height;
	image->color_type = info_ptr->color_type;
	image->bit_depth = info_ptr->bit_depth;
	
	png_set_interlace_handling(png_ptr);
	png_read_update_info(png_ptr, info_ptr);
	
	/* read file */
	if (setjmp(png_jmpbuf(png_ptr)))
		abort_("[read_png_file] Error during read_image");
	
	image->row_pointers = (png_bytep*) malloc(sizeof(png_bytep) * image->height);
	for (int y=0; y<image->height; y++)
		image->row_pointers[y] = (png_byte*) malloc(info_ptr->rowbytes);
	
	png_read_image(png_ptr, image->row_pointers);
	
	fclose(fp);
	
	return image;
}


void write_png_file(const char* file_name, Image* image)
{
	/* create file */
	FILE *fp = fopen(file_name, "wb");
	if (!fp)
		abort_("[write_png_file] File %s could not be opened for writing", file_name);
	
	
	/* initialize stuff */
	png_structp png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	
	if (!png_ptr)
		abort_("[write_png_file] png_create_write_struct failed");
	
	png_infop info_ptr = png_create_info_struct(png_ptr);
	if (!info_ptr)
		abort_("[write_png_file] png_create_info_struct failed");
	
	if (setjmp(png_jmpbuf(png_ptr)))
		abort_("[write_png_file] Error during init_io");
	
	png_init_io(png_ptr, fp);
	
	
	/* write header */
	if (setjmp(png_jmpbuf(png_ptr)))
		abort_("[write_png_file] Error during writing header");
	
	png_set_IHDR(png_ptr, info_ptr, image->width, image->height,
				 image->bit_depth, image->color_type, PNG_INTERLACE_NONE,
				 PNG_COMPRESSION_TYPE_BASE, PNG_FILTER_TYPE_BASE);
	
	png_write_info(png_ptr, info_ptr);
	
	
	/* write bytes */
	if (setjmp(png_jmpbuf(png_ptr)))
		abort_("[write_png_file] Error during writing bytes");
	
	png_write_image(png_ptr, image->row_pointers);
	
	
	/* end write */
	if (setjmp(png_jmpbuf(png_ptr)))
		abort_("[write_png_file] Error during end of write");
	
	png_write_end(png_ptr, NULL);
	
	fclose(fp);
}

void release_image(Image *image) {
	/* cleanup heap allocation */
	for (int y=0; y<image->height; y++)
		free(image->row_pointers[y]);
	free(image->row_pointers);
	free(image);
}
