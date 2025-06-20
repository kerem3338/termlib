/*
filled_buffer_color.d: Example usage of ColoredBuffer.

Author : Zoda
License: MIT
Date   : 18/06/2025
*/
import termlib;
import std.stdio;

void main() {
	ColoredBuffer buffer = new ColoredBuffer();
	buffer.fg = Colors.red;
	buffer.bg = Colors.white;

	buffer.setSize(25,15);
	buffer.fill('#');
	write(buffer.getAsColored());

}