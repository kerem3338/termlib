/*
text.d: Example usage of write functions.

Author : Zoda
License: MIT
Date   : 02/06/2025
*/
import termlib;
import std.stdio;

void main() {
	CharBuffer buffer;

	buffer.setSize(25,15);
	buffer.fill(' ');

	buffer.writeAt(14, 0, "Hello World");
	buffer.writeCentered("Hello World");
	buffer.writeAt(0, 14, "Hello World");

	write(buffer.getAsString());

}