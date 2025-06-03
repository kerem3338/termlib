/*
paint.d: *Simple* paint application example.

Author : Zoda
License: MIT
Date   : 02/06/2025
*/
import termlib;
import std.stdio;

void main() {
	CharBuffer srcBuffer;
	CharBuffer frontBuffer;

	uint pointerX, pointerY = 0;
	char currentChar = '*';
	bool run = true;

	frontBuffer.setSize(25, 15);
	frontBuffer.fill(' ');

	srcBuffer.setSize(25,15);
	srcBuffer.fill(' ');


	setCursorPosition(0, 16);
	write("[q] Exit [space] Paint [f] Fill Entire Canvas  [1] ' ' | [2] '*'");

	hideCursor();
	while (run) {
		frontBuffer.data = srcBuffer.data.dup;

		frontBuffer.setAt(pointerX, pointerY, currentChar);
		frontBuffer.setAt(pointerX, pointerY + 1, '^');

		setCursorPosition(0,0);
		write(frontBuffer.getAsString());

		

		if (kbhit() != 0) {
			char ch = cast(char) getch();

			switch (ch) {
				case '1':
					currentChar = ' ';
					break;
				case '2':
					currentChar = '*';
					break;
				case 'q':
					run = false;
					break;
				case 'f':
					srcBuffer.fill(currentChar);
					break;
				case AsciiKeys.space:
					srcBuffer.setAt(pointerX, pointerY, currentChar);
					break;
				case AsciiKeys.upArrow:
					if (pointerY > 0) {
						pointerY--;
					}
					break;
				case AsciiKeys.downArrow:
					if (pointerY < srcBuffer.height - 1) {
						pointerY++;
					}
					break;
				case AsciiKeys.leftArrow:
					if (pointerX > 0) pointerX--;
					break;
				case AsciiKeys.rightArrow:
					if (pointerX < srcBuffer.width - 1) pointerX++;
					break;
				default: break;
			}
		}

	}
	showCursor();

}