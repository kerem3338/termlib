/*
jump_game.d: Example game using termlib.

Author : Zoda
License: MIT
Date   : 02/06/2025
*/
import termlib;
import std.stdio;
import std.format;
import core.thread : Thread;
import std.datetime;

void main() {
	CharBuffer srcBuffer = new CharBuffer();
	CharBuffer frontBuffer = new CharBuffer();

	string[] playerAnimation = ["<$._.$>","<$>.<$>",];
	int currentFrame = 0;

	bool run = true;
	int score = 0;
	int playerY = 5;

	
	frontBuffer.setSize(80,15);
	frontBuffer.fill(' ');

	srcBuffer.setSize(80,15);
	srcBuffer.fill(' ');
	srcBuffer.fillArea(URect(0,13,80,2), '$');
	
	hideCursor();
	while (run) {
		frontBuffer.data = srcBuffer.data.dup;

		frontBuffer.writeAt(0,0, format("Score: %d",score));
		frontBuffer.writeWidthCentered(playerY, playerAnimation[currentFrame]);

		setCursorPosition(0,0);
		write(frontBuffer.getAsString());
		
		if (kbhit() != 0) {
			char ch = cast(char) getch();

			switch (ch) {
				case AsciiKeys.space:
					if (playerY <= 1) break;

					playerY -= 2;
					break;
				case 'q':
					run = false;
					break;
				default: break;
			}
		}

		/** Logic **/
		currentFrame = (currentFrame + 1) % playerAnimation.length;


		if (playerY >= srcBuffer.height - 1) {
			score--;
			playerY = srcBuffer.height - 1;
		} else {
			playerY++;
			score++;
		}

		Thread.sleep(100.msecs);
	}
	showCursor();
}