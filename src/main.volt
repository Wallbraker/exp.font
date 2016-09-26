module main;

import lib.stb.truetype;

import watt.io;
import watt.io.file;

extern(C) fn putchar(char);

fn main(args: string[]) int
{
	font: stbtt_fontinfo;
	bitmap: ubyte*;
	w: int;
	h: int;
	c := 'a';
	s := 20;

	file := read("font.ttf");
	off := stbtt_GetFontOffsetForIndex(file.ptr, 0);
	ret := stbtt_InitFont(&font, file.ptr, off);
	scale := stbtt_ScaleForPixelHeight(&font, cast(float)s);

	bitmap = cast(ubyte*)stbtt_GetCodepointBitmap(&font, 0.f, scale, c, &w, &h, null, null);

	foreach (j; 0 .. h) {
		foreach (i; 0 .. w) {
			putchar(" .:ioVM@"[bitmap[j * w + i] >> 5]);
		}
		putchar('\n');
	}

	return 0;
}
