/*
randomness.d: Randomly painted buffer.

Author : Zoda
License: MIT
Date   : 02/06/2025
*/
import termlib;
import std.stdio;
import std.random;

void main() {
	CharBuffer buffer = new CharBuffer();
	Size termSize = getConsoleSize();

	buffer.setSize(termSize);
	buffer.fill(' ');

	auto rng = Random(unpredictableSeed);
	bool run = true;

	hideCursor();

	while (run) {
		uint x = uniform(0, buffer.width, rng);
		uint y = uniform(0, buffer.height, rng);
		
		char chr = cast(char) uniform(32, 127, rng);
		buffer.setAt(x, y, chr);

		setCursorPositionOS(0,0);
		write(buffer.getAsString());

		if (kbhit() != 0) {
			char ch = cast(char) getch();

			if (ch == 'q') run = false;
		}
	}

	showCursor();
}