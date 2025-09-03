/*
win_paint.d: Windows only paint program.

Author : Zoda
License: MIT
Date   : 07/06/2025
*/
import termlib;
import std.path;
import std.stdio;
import core.thread : Thread;
import std.datetime;
import std.string: strip;
import std_file = std.file;

import core.sys.windows.windows;

pragma(lib, "user32");

void saveDialog(CharBuffer* _srcBuffer) {
	setCursorPositionOS(0,0);

	showCursor();
		write("Path to save [empty path = cancel]: ");
		string savePath = readln();
	hideCursor();

	savePath = strip(savePath);

	if (savePath == "") return;

	string fileExt = extension(savePath);

	std_file.write(savePath, _srcBuffer.getAsString());
	

}

void srcWrite(CharBuffer* _srcBuffer, uint pointerX, uint pointerY) {
	setCursorPositionOS(pointerX, pointerY);

	showCursor();
		string inp = readln();
	hideCursor();

	if (inp.length > 1) {
		inp = inp[0..$-1];
		_srcBuffer.writeAt(pointerX, pointerY, inp);
	}

	
}
void main() {
	fixWindows();

	CharBuffer srcBuffer = new CharBuffer();
	CharBuffer frontBuffer = new CharBuffer();

	uint pointerX, pointerY = 0;
	uint firstX, firstY, lastX, lastY = 0;
	wchar currentChar = '*';
	bool run = true;
	Size termSize = getConsoleSize();
	
	srcBuffer.setSize(termSize.w, termSize.h - 10);
	frontBuffer.setSize(termSize.w, termSize.h - 10);

	setConsoleTitleOS("Win Paint");
	hideCursor();

	setCursorPositionOS(0, termSize.h - 8);
	write(getStyled("Win Paint By Zoda", false, true));
	setCursorPositionOS(0, termSize.h - 6);
	write("[end] X End [home] X Home [w] Write to buffer [f1] Save dialog");
	setCursorPositionOS(0, termSize.h - 5);
	write("[space] Paint [f] Fill the entire buffer [p] Pick color [escape] Exit");
	setCursorPositionOS(0, termSize.h - 3);
	write("[1] ' ' [2] '*' [3] '█' [4] '☺' [5] '♦' [6] '░'");
	
	while (run) {
		frontBuffer.data = srcBuffer.data.dup;

		frontBuffer.setAt(pointerX, pointerY, currentChar);
		frontBuffer.setAt(pointerX, pointerY + 1, '^');

		setCursorPositionOS(0,0);
		write(frontBuffer.getAsString());

		if (GetAsyncKeyState(VK_UP) & 0x8000 && pointerY > 0) pointerY--;
		if (GetAsyncKeyState(VK_DOWN) & 0x8000 && pointerY < termSize.h - 1) pointerY++;
		if (GetAsyncKeyState(VK_LEFT) & 0x8000 && pointerX > 0) pointerX--;
		if (GetAsyncKeyState(VK_RIGHT) & 0x8000 && pointerX < termSize.w - 1) pointerX++;
		if (GetAsyncKeyState(VK_SPACE) & 0x8000) srcBuffer.setAt(pointerX, pointerY, currentChar);
		if (GetAsyncKeyState(VK_END) & 0x8000) pointerX = srcBuffer.width - 1;
		if (GetAsyncKeyState(VK_HOME) & 0x8000) pointerX = 0;
		if (GetAsyncKeyState('F') & 0x8000) srcBuffer.fill(currentChar);
		if (GetAsyncKeyState('P') & 0x8000) currentChar = srcBuffer.getAt(pointerX, pointerY);
		if (GetAsyncKeyState('W') & 0x8000) srcWrite(&srcBuffer, pointerX, pointerY);
		if (GetAsyncKeyState('1') & 0x8000) currentChar = ' ';
		if (GetAsyncKeyState('2') & 0x8000) currentChar = '*';
		if (GetAsyncKeyState('3') & 0x8000) currentChar = '█';
		if (GetAsyncKeyState('4') & 0x8000) currentChar = '☺';
		if (GetAsyncKeyState('5') & 0x8000) currentChar = '♦';
		if (GetAsyncKeyState('6') & 0x8000) currentChar = '░';
		if (GetAsyncKeyState(VK_F1) & 0x8000) saveDialog(&srcBuffer);
		if (GetAsyncKeyState(VK_ESCAPE) & 0x8000) run = false;


		Thread.sleep(50.msecs);
	}
	showCursor();
}