/*
animation.d: Example animation using termlib.

Author : Zoda
License: MIT
Date   : 03/06/2025
*/
import termlib;
import std.stdio;
import core.thread : Thread;
import std.datetime;

void main() {
	CharBuffer buffer;

	string[] frames     = ["<$>-_<$>","<$>_-<$>","<$>--<$>"];
	size_t currentFrame = 0;
	bool run            = true;
	Size termSize       = getTerminalSize();


	buffer.setSize(termSize.w, termSize.h - 1);
	buffer.fill(' ');

	hideCursor();
	while (run) {
		currentFrame = (currentFrame + 1) % frames.length;
		
		if (kbhit() != 0) {
			char key = cast(char) getch();

			if (key == 'q') run = false;
		}
		
		buffer.fill(' ');
		buffer.writeC(frames[currentFrame]);

		setCursorPosition(0,0);
		write(buffer.getAsString());

		Thread.sleep(100.msecs);
	}
	showCursor();
}