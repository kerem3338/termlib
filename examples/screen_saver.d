/*
screen_saver.d: DVD like screen saver written using Termlib

Author : Zoda
License: MIT
Date   : 06/12/2025
*/
import termlib;
import std.stdio;
import std.random;
import std.typecons;
import core.thread: Thread;
import std.datetime;

void main() {
	Size termSize = getConsoleSize();

	ColoredBuffer src = new ColoredBuffer();
	src.setSize(termSize.w, termSize.h);

	int xDir = 1;
	int yDir = 1;

	immutable string dvdText = "DVD";
	uint dvdW = dvdText.length;
	uint dvdH = 1;
	
	auto rnd = Random(unpredictableSeed);
	Tuple!(Color, Color)[] colorCombinations = [
		tuple(Colors.red, Colors.blue),
		tuple(Colors.yellow, Colors.white),
		tuple(Colors.green, Colors.grey),
		tuple(Colors.black, Colors.white),
		tuple(Colors.darkBlue, Colors.white)
	];

	Color textFg = Colors.red;
	Color textBg = Colors.blue;
	
	 URect rect = URect(
		(src.width  - dvdW) / 2,
		(src.height - dvdH) / 2,
		dvdW,
		dvdH
	 );

	hideCursor();

	while (true) {
		if (kbhit() != 0) {
			char ch = cast(char) getch();
			if (ch == 'q') break;
		}
		
		rect.x += xDir;
		rect.y += yDir;

		if (rect.x == 0 || rect.x + rect.w >= src.width) {
			Tuple!(Color, Color) combination = colorCombinations[uniform(0, colorCombinations.length, rnd)];
			textFg = combination[0];
			textBg = combination[1];
			
			xDir *= -1;
		}

		if (rect.y == 0 || rect.y + rect.h >= src.height) {
			Tuple!(Color, Color) combination = colorCombinations[uniform(0, colorCombinations.length, rnd)];
			textFg = combination[0];
			textBg = combination[1];
			yDir *= -1;
		}

		src.fill(' ');
		src.writeAtColored(textFg, textBg, rect.x, rect.y, dvdText);

		setCursorPositionOS(0, 0);
		write(src.getAsColored());

		Thread.sleep(120.msecs);
	}

	showCursor();
}