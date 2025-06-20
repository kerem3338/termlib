/*
filled_buffer.d: Example usage of CharBuffer.

Author : Zoda
License: MIT
Date   : 02/06/2025
*/
import termlib;
import std.stdio;

void main() {
	CharBuffer buffer = new CharBuffer();

	buffer.setSize(25,15);
	buffer.fill('#');
	write(buffer.getAsString());

}