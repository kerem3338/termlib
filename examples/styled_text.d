/*
styled_text.d: Example usage getStyled function.

Author : Zoda
License: MIT
Date   : 03/06/2025
*/
import termlib;
import std.stdio;

void main() {
	write(getStyled("Italic Text", false, true, false));
	write("\n");
	write(getStyled("Text with underline", true, false, false));
}