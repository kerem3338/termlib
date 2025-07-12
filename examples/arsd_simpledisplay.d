/*
arsd_simpledisplay.d: arsd.simpledisplay with Termlib

NOTE: this is not a very good example usage of arsd.simpledisplay. I'm learning simpledisplay as well
External Requirements:
	- arsd.simpledisplay (https://raw.githubusercontent.com/adamdruppe/arsd/refs/heads/master/simpledisplay.d)
	- arsd.color         (https://raw.githubusercontent.com/adamdruppe/arsd/refs/heads/master/color.d)
	- arsd.core          (https://raw.githubusercontent.com/adamdruppe/arsd/refs/heads/master/core.d)

How To Build:
	1. Build With DMD
		$ dmd simpledisplay.d core.d color.d termlib.d <yourfile>.d -of=<executable_name>

Author : Zoda
License: MIT
Date   : 12/07/2025
*/
import std;
import termlib;
import arsd.simpledisplay;
import std.conv;

void main() {
	bool init = false;
	auto window = new SimpleWindow(arsd.simpledisplay.Size(500,500), "arsd.simpledisplay with Termlib");
	
	ColoredBuffer srcBuffer = new ColoredBuffer();
	
	srcBuffer.setSize(33, 33);
	srcBuffer.setColor(Colors.yellow, Colors.black);
	srcBuffer.fill('*');
	
	srcBuffer.setColor(Colors.green, Colors.black);
	srcBuffer.writeC("Hello World");

	window.eventLoop(50,
		delegate() {
			auto painter  = window.draw();
			painter.clear();
			
			// Don't know any other way to do it (for now)
			if (!init) {
				window.resize(20 * painter.fontHeight, 20 * painter.fontHeight);
				init = true;
			}

			int x,y = 0;
		
			for (int i = 0; i < srcBuffer.data.length; i++) {
				if (x == srcBuffer.width) {
					x = 0;
					y ++;
				}

				termlib.Color fg = srcBuffer.fgData[i];
				termlib.Color bg = srcBuffer.bgData[i];

				auto arsd_fg = arsd.color.Color(fg.r, fg.b, fg.g, fg.a);
				auto arsd_bg = arsd.color.Color(fg.r, fg.b, fg.g, fg.a);

				painter.outlineColor = arsd_fg;
				painter.fillColor = arsd_bg;

				painter.drawText(arsd.simpledisplay.Point(x * painter.fontHeight, y * painter.fontHeight), srcBuffer.data[i].to!string);
				x++;
			}
				
		}
	);
}