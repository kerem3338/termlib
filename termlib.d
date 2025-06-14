/*
 ________                                 __  __  __       
/        |                               /  |/  |/  |      
$$$$$$$$/______    ______   _____  ____  $$ |$$/ $$ |____  
   $$ | /      \  /      \ /     \/    \ $$ |/  |$$      \ 
   $$ |/$$$$$$  |/$$$$$$  |$$$$$$ $$$$  |$$ |$$ |$$$$$$$  |
   $$ |$$    $$ |$$ |  $$/ $$ | $$ | $$ |$$ |$$ |$$ |  $$ |
   $$ |$$$$$$$$/ $$ |      $$ | $$ | $$ |$$ |$$ |$$ |__$$ |
   $$ |$$       |$$ |      $$ | $$ | $$ |$$ |$$ |$$    $$/ 
   $$/  $$$$$$$/ $$/       $$/  $$/  $$/ $$/ $$/ $$$$$$$/  

Termlib is a project by Zoda (github.com/kerem338)

Very basic but usefull terminal manipulation library.


Note:
	** If you are a windows user and buffer contents seems broken, run `chcp 65001` at your terminal.

This project licensed under MIT license.
*/
module termlib;

import std.stdio;
import std.variant;
import std.conv;
import core.stdc.stdio;
import std.format;

extern (C) int kbhit();
extern (C) int getch();

const string __version__ = "0.1.0";

version(Windows) {
	import core.sys.windows.windows;
	import std.string: toStringz;
}

enum AsciiKeys {
	upArrow = 72,
	downArrow = 80,
	leftArrow = 75,
	rightArrow = 77,
	space = 32
}

struct Styles {
	enum string underlineBegin = "\033[4m";
	enum string italicBegin    = "\033[3m";
	enum string blinkingBegin  = "\033[5m";
	enum string boldBegin      = "\033[1m";

	enum string underlineEnd   = "\033[24m";
	enum string italicEnd      = "\033[23m";
	enum string blinkingEnd    = "\033[25m";
	enum string boldEnd        = "\033[22m";
	enum string reset          = "\033[0m";
}

struct Ansi {
	enum string setCursorPosition = "\033[%d;%dH";
	enum string showCursor = "\033[?25h";
	enum string hideCursor = "\033[?25l";
	enum string getColored = "\033[38;2;%d;%d;%dm%s\033[0m";
}

void setCursorPositionOS(int x, int y) {
	version (Windows) {
		SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), COORD(cast(short)x, cast(short)y));
	} else {
		setCursorPosition(x, y);
	}
}

void setCursorPosition(int x, int y) {
	writef(Ansi.setCursorPosition, y + 1 ,x + 1);
}

void hideCursor() {
	write(Ansi.hideCursor);
}

void showCursor() {
	write(Ansi.showCursor);
}

string getColored(int r, int g, int b, string text) {
	return format(Ansi.getColored, r, g, b, text);
}

string getStyled(string text, bool underline = false, bool italic = false, bool blinking = false, bool bold = false) {
	string _content = ""; 
	// begin
	if (underline) _content ~= "\033[4m";
	if (italic) _content ~= "\033[3m";
	if (blinking) _content ~= "\033[5m";
	if (bold) _content ~= "\033[1m";

	_content ~= text;

	// end
	if (underline) _content ~= "\033[24m";
	if (italic) _content ~= "\033[23m";
	if (blinking) _content ~= "\033[25m";
	if (bold) _content ~= "\033[22m";

	return _content;
}

/*
Function for getting console size

Returns:
	Size

Supported Platforms:
	Windows only for now.
*/
Size getConsoleSize() {
	Size size = Size(0,0);
	version (Windows) {
		CONSOLE_SCREEN_BUFFER_INFO csbi;
		GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi);
		size.width = csbi.dwSize.X;
		size.height = csbi.dwSize.Y;
	}

	return size;
}

/*
Function for setting console title

Supported Platforms:
	Windows only for now.
*/
void setConsoleTitleOS(string title) {
	version (Windows) {
		if(title.length > MAX_PATH) title = title[0..MAX_PATH];
		SetConsoleTitleA(toStringz(title));
	}
}
struct URect {
	uint x;
	uint y;
	uint w;
	uint h;

	bool checkPoint(Point point) {
			return point.x >= x && point.x < x + w &&
				point.y >= y && point.y < y + h;
	}
}

struct Point {
	int x;
	int y;
}

struct UPoint {
	uint x;
	uint y;
}

struct Size {
	uint width;
	uint height;

	alias w = width;
	alias h = height;
}

struct CharBuffer {
	wchar[] data;
	uint width;
	uint height;


	alias writeWC = writeWidthCentered;
	alias writeHC = writeHeightCentered;
	alias writeC = writeCentered;
	alias drawER = drawEmptyRect;
	
	void setSize(uint w, uint h) {
		width = w;
		height = h;
		data.length = w * h;
		data[] = ' ';
	}

	void setAt(uint x, uint y, wchar chr) {
		if (!isValidPosition(x,y)) return;

		data[y * width + x] = chr;
	}

	void fill(wchar chr) {
		data[] = chr;
	}

	wchar getAt(uint x, uint y) {
		if (!isValidPosition(x,y)) {
			return '\0';
		}

		return data[y * width + x];

	}

	bool isValidPosition(uint x, uint y) {
		return x < width && y < height;
	}


	void writeAt(uint x, uint y, string text) {
		for (int i = 0; i < text.length; i++) {
			wchar chr = text[i];
			setAt(x + i, y , chr);
		}
	}

	void writeWidthCentered(uint y, string text) {
		uint x = width / 2 - text.length / 2;
		writeAt(x, y, text); 
	}

	void writeHeightCentered(uint x, string text) {
		uint y = height / 2;
		writeAt(x, y, text); 
	}

	void writeCentered(string text) {
		uint x = width / 2 - cast(uint)(text.length / 2);
		uint y = height / 2;
		writeAt(x, y, text);
	}

	URect writeCenteredRect(string text) {
		uint x = width / 2 - cast(uint)(text.length / 2);
		uint y = height / 2;
		writeAt(x, y, text);

		return URect(x, y, text.length, 1);
	}


	CharBuffer getsubArea(URect rect) {
		CharBuffer subBuffer;
		subBuffer.setSize(rect.w, rect.h);
		subBuffer.fill(' ');

		for (int y = 0; y < rect.h; y++) {
			for (int x = 0; x < rect.w; x++) {
				int destX = rect.x + x;
				int destY = rect.y + y;
				
				if (destX >= this.width || destY >= this.height || destX < 0 || destY < 0)
					continue;
					
				subBuffer.setAt(destX, destY, this.getAt(destX, destY));
			}
		}
		
		return subBuffer;
	}

	void drawBuffer(uint whereX, uint whereY, CharBuffer otherBuffer) {
		for (int y = 0; y < otherBuffer.height; y++) {
			for (int x = 0; x < otherBuffer.width; x++) {
				int destX = whereX + x;
				int destY = whereY + y;

				if (destX >= this.width || destY >= this.height || destX < 0 || destY < 0)
					continue;

				setAt(destX, destY, otherBuffer.getAt(x,y));
			}
		}
	}
	
	void drawEmptyRect(URect rect, wchar chr) {
		uint right = rect.x + rect.w - 1;
		uint bottom = rect.y + rect.h - 1;
		
		for (uint x = rect.x; x <= right; x++) {
			setAt(x, rect.y, chr);
			setAt(x, bottom, chr);
		}
		
		for (uint y = rect.y + 1; y < bottom; y++) {
			setAt(rect.x, y, chr);
			setAt(right, y, chr);
		}
	}

	void fillArea(URect rect, wchar chr) {
		for (int y = 0; y < rect.h; y++) {
			for (int x = 0; x < rect.w; x++) {
				uint destX = x + rect.x;
				uint destY = y + rect.y;

				setAt(destX, destY, chr);

			}
		}
	}


	void drawBufferSkip(uint whereX, uint whereY, CharBuffer otherBuffer, wchar charToSkip) {
		for (int y = 0; y < otherBuffer.height; y++) {
			for (int x = 0; x < otherBuffer.width; x++) {
				int destX = whereX + x;
				int destY = whereY + y;               
				wchar value = otherBuffer.getAt(x,y);

				if (destX >= this.width || destY >= this.height || destX < 0 || destY < 0)
					continue;

				if (value == charToSkip) continue;
				setAt(destX, destY, value);
			}
		}
	}

	string getAsString() {
		int x = 0;
		string value;
		
		for (int i = 0; i < data.length; i++) {
			if (x == width) {
				x = 0;
				value ~= "\n";
			}

			value ~= data[i];
			x++;
		}

		return value;
	}

}

CharBuffer mergeBuffers(CharBuffer[] buffers, uint width, uint height, wchar emptyCellChar) {
	CharBuffer mergedBuffer;
	mergedBuffer.setSize(width, height);
	mergedBuffer.fill(emptyCellChar);

	foreach (CharBuffer buffer; buffers) {
		mergedBuffer.drawBufferSkip(0,0,buffer,emptyCellChar);
	}
	return mergedBuffer;
}

/**
A function for converting buffer data to Terminal Text Image format version

Params:
	Charbuffer buffer: Buffer to convert
Returns:
	str
**/
string bufferToTTI(CharBuffer buffer) {
	string outSrc = "TTI 1\n";
	outSrc ~= format("%d %d\n---\n", buffer.width, buffer.height);

	int x, y = 0;
	foreach (wchar ch; buffer.data) {
		outSrc ~= ch;
		x += 1;

		if (x == buffer.width) {
			x = 0;
			y++;
			outSrc ~= "\n";
		}
	}
	return outSrc;
}

unittest {
	CharBuffer buffer;
	buffer.setSize(1,1);
	buffer.fill('#');

	assert(buffer.getAt(0,0) == '#');
}

unittest {
	CharBuffer buffer;
	buffer.setSize(10,10);
	assert(buffer.isValidPosition(1,1));
}

// Is everything fine?
unittest {
	assert(1 == 1);
}