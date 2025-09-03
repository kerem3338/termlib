# Colored Buffer

`ColoredBuffer` is an abstraction over `CharBuffer`
with color information for each cell.

ColoredBuffer stores each cells color information on `fgData` and `bgData` arrays

## Notes
* Termlib uses the foreground as the first argument and the background as the second in most cases.
* Termlib uses `Color` struct to represent an cell color in RGBA format

## Most Common Functions
`fill` fills the entire buffer with given character

`fillColored` fills the entire buffer with given character and the color information

`writeAtColored` inserts text at given position with color information

`setColor` changes current color of foreground and background

Example Usage:
```d
// hello.d
import termlib;
import std.stdio;

void main() {
	ColoredBuffer buffer = new ColoredBuffer();
	buffer.setSize(10,10);

	buffer.writeAtColored(Colors.red, Colors.yellow, 2, 5, "Hello!");
	write(buffer.getAsColored());
}
```
Use `build build hello.d` or `dmd termlib.d hello.d -of=hello.d` to build.
