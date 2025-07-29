/*
insert_from_file.d: Example usage of insertFromFile

Author : Zoda
License: MIT
Date   : 28/07/2025
*/
import termlib;
import std.stdio;
import std.file;
import std.path;

void main() {
	CharBuffer buffer = new CharBuffer();
	buffer.setSize(7,4);

	buffer.insertFromFile(buildPath(dirName(thisExePath), "assets", "face.txt"), 0, 0);
	write(buffer.getAsString());
}