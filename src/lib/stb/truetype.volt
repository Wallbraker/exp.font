
module lib.std.truetype;

extern(C):



//////////////////////////////////////////////////////////////////////////////
//
// FONT LOADING
//
//

fn stbtt_GetFontOffsetForIndex(data: const(void)*, index: int) int;
// Each .ttf/.ttc file may have more than one font. Each font has a sequential
// index number starting from 0. Call this function to get the font offset for
// a given index; it returns -1 if the index is out of range. A regular .ttf
// file will only define one font and it always be at offset 0, so it will
// return '0' for index 0, and -1 for all other indices. You can just skip
// this step if you know it's that kind of font.


// The following structure is defined publically so you can declare one on
// the stack or as a global or etc, but you should treat it as opaque.
struct stbtt_fontinfo
{
	userdata: void*;
	data: void*;                        // pointer to .ttf file
	fontstart: int;                     // offset of start of font

	numGlyphs: int;                     // number of glyphs, needed for range checking

	loca,head,glyf,hhea,hmtx,kern: int; // table locations as offset from start of .ttf
	index_map: int;                     // a cmap mapping for our chosen character encoding
	indexToLocFormat: int;              // format needed to map from glyph index to glyph
}

fn stbtt_InitFont(
	info: stbtt_fontinfo*, data: void*, offset: int) int;


//////////////////////////////////////////////////////////////////////////////
//
// CHARACTER TO GLYPH-INDEX CONVERSIOn

fn stbtt_FindGlyphIndex(
	info: const(stbtt_fontinfo)*, unicode_codepoint: int) int;
// If you're going to perform multiple operations on the same character
// and you want a speed-up, call this function with the character you're
// going to process, then use glyph-based functions instead of the
// codepoint-based functions.


//////////////////////////////////////////////////////////////////////////////
//
// CHARACTER PROPERTIES
//

fn stbtt_ScaleForPixelHeight(
	info: const(stbtt_fontinfo)*, pixels: float) float;
// computes a scale factor to produce a font whose "height" is 'pixels' tall.
// Height is measured as the distance from the highest ascender to the lowest
// descender; in other words, it's equivalent to calling stbtt_GetFontVMetrics
// and computing:
//       scale = pixels / (ascent - descent)
// so if you prefer to measure height by the ascent only, use a similar calculation.

fn stbtt_ScaleForMappingEmToPixels(
	info: const(stbtt_fontinfo)*, pixels: float) float;
// computes a scale factor to produce a font whose EM size is mapped to
// 'pixels' tall. This is probably what traditional APIs compute, but
// I'm not positive.

fn stbtt_GetFontVMetrics(
	info: const(stbtt_fontinfo)*, ascent: int*, descent: int*, lineGap: int*);
// ascent is the coordinate above the baseline the font extends; descent
// is the coordinate below the baseline the font extends (i.e. it is typically negative)
// lineGap is the spacing between one row's descent and the next row's ascent...
// so you should advance the vertical position by "*ascent - *descent + *lineGap"
//   these are expressed in unscaled coordinates, so you must multiply by
//   the scale factor for a given size

fn stbtt_GetFontBoundingBox(
	info: const(stbtt_fontinfo)*, x0: int*, y0: int*, x1: int*, y1: int*);
// the bounding box around all possible characters

fn stbtt_GetCodepointHMetrics(
	info: const(stbtt_fontinfo)*, codepoint: int, advanceWidth: int*, leftSideBearing: int*);
// leftSideBearing is the offset from the current horizontal position to the left edge of the character
// advanceWidth is the offset from the current horizontal position to the next horizontal position
//   these are expressed in unscaled coordinates

fn stbtt_GetCodepointKernAdvance(
	info: const(stbtt_fontinfo)*, ch1: int, ch2: int) int;
// an additional amount to add to the 'advance' value between ch1 and ch2

fn stbtt_GetCodepointBox(
	info: const(stbtt_fontinfo)*, codepoint: int, x0: int*, y0: int*, x1: int*, y1: int*) int;
// Gets the bounding box of the visible part of the glyph, in unscaled coordinates

fn stbtt_GetGlyphHMetrics(
	info: const(stbtt_fontinfo)*, glyph_index: int, advanceWidth: int*, leftSideBearing: int*);
fn stbtt_GetGlyphKernAdvance(
	info: const(stbtt_fontinfo)*, glyph1: int, glyph2: int) int;
fn stbtt_GetGlyphBox(
	info: const(stbtt_fontinfo)*, glyph_index: int, x0: int*, y0: int*, x1: int*, y1: int*) int;
// as above, but takes one or more glyph indices for greater efficiency



//////////////////////////////////////////////////////////////////////////////
//
// BITMAP RENDERING
//

fn stbtt_FreeBitmap(bitmap: void*, userdata: void*);
// frees the bitmap allocated below

fn stbtt_GetCodepointBitmap(info: const(stbtt_fontinfo)*,
	scale_x: float, scale_y: float, codepoint: int,
	width: int*, height: int*, xoff: int*, yoff: int*) void*;
// allocates a large-enough single-channel 8bpp bitmap and renders the
// specified character/glyph at the specified scale into it, with
// antialiasing. 0 is no coverage (transparent), 255 is fully covered (opaque).
// *width & *height are filled out with the width & height of the bitmap,
// which is stored left-to-right, top-to-bottom.
//
// xoff/yoff are the offset it pixel space from the glyph origin to the top-left of the bitmap

fn stbtt_GetCodepointBitmapSubpixel(
	info: const(stbtt_fontinfo)*, scale_x: float, scale_y: float,
	shift_x: float, shift_y: float, codepoint: int,
	width: int*, height: int*, xoff: int*, yoff: int*) void*;
// the same as stbtt_GetCodepoitnBitmap, but you can specify a subpixel
// shift for the character

fn stbtt_MakeCodepointBitmap(
	info: const(stbtt_fontinfo)*, output: void*,
	out_w: int, out_h: int, out_stride: int,
	scale_x: float, scale_y: float, codepoint: int);
// the same as stbtt_GetCodepointBitmap, but you pass in storage for the bitmap
// in the form of 'output', with row spacing of 'out_stride' bytes. the bitmap
// is clipped to out_w/out_h bytes. Call stbtt_GetCodepointBitmapBox to get the
// width and height and positioning info for it first.

fn stbtt_MakeCodepointBitmapSubpixel(
	info: const(stbtt_fontinfo)*, output: void*,
	out_w: int, out_h: int, out_stride: int,
	scale_x: float, scale_y: float,
	shift_x: float, shift_y: float, codepoint: int);
// same as stbtt_MakeCodepointBitmap, but you can specify a subpixel
// shift for the character

fn stbtt_GetCodepointBitmapBox(info: const(stbtt_fontinfo)*, codepoint: int, scale_x: float, scale_y: float, ix0: int*, iy0: int*, ix1: int*, iy1: int*);
// get the bbox of the bitmap centered around the glyph origin; so the
// bitmap width is ix1-ix0, height is iy1-iy0, and location to place
// the bitmap top left is (leftSideBearing*scale,iy0).
// (Note that the bitmap uses y-increases-down, but the shape uses
// y-increases-up, so CodepointBitmapBox and CodepointBox are inverted.)

fn stbtt_GetCodepointBitmapBoxSubpixel(info: const(stbtt_fontinfo)*, codepoint: int, scale_x: float, scale_y: float, shift_x: float, shift_y: float, ix0: int*, iy0: int*, ix1: int*, iy1: int*);
// same as stbtt_GetCodepointBitmapBox, but you can specify a subpixel
// shift for the character

// the following functions are equivalent to the above functions, but operate
// on glyph indices instead of Unicode codepoints (for efficiency)
fn stbtt_GetGlyphBitmap(
	info: const(stbtt_fontinfo)*, scale_x: float, scale_y: float,
	glyph: int, width: int*, height: int*, xoff: int*, yoff: int*) void*;
fn stbtt_GetGlyphBitmapSubpixel(
	info: const(stbtt_fontinfo)*, scale_x: float, scale_y: float,
	shift_x: float, shift_y: float, glyph: int,
	width: int*, height: int*, xoff: int*, yoff: int*) void*;
fn stbtt_MakeGlyphBitmap(
	info: const(stbtt_fontinfo)*, output: void*, out_w: int, out_h: int,
	out_stride: int, scale_x: float, scale_y: float, glyph: int);
fn stbtt_MakeGlyphBitmapSubpixel(
	info: const(stbtt_fontinfo)*, output: void*,
	out_w: int, out_h: int, out_stride: int, scale_x:
	float, scale_y: float, shift_x: float, shift_y: float, glyph: int);
fn stbtt_GetGlyphBitmapBox(
	info: const(stbtt_fontinfo)*, glyph: int, scale_x: float, scale_y: float,
	ix0: int*, iy0: int*, ix1: int*, iy1: int*);
fn stbtt_GetGlyphBitmapBoxSubpixel(
	info: const(stbtt_fontinfo)*, glyph: int, scale_x: float, scale_y: float,
	shift_x: float, shift_y: float, ix0: int*, iy0: int*, ix1: int*, iy1: int*);
