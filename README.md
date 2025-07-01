# Termlib

Small terminal manipulation library for D Programming Language.

## Getting Started
First you need to build `build.d` program, with following command.
```shell
dmd build.d
```
Then you can build termlib examples with following command
```
build.exe build-examples
```
And finally run with
```
.\examples\filled_buffer.exe
```

## Example Usage
```d
import termlib;
import std.stdio;

void main() {
	CharBuffer buffer = new CharBuffer();

	buffer.setSize(25,15);
	buffer.fill('#');

	buffer.writeCentered("Hello World");

	write(buffer.getAsString());

}
```
*To compile: `build.exe build hello_world.d`*

**For more examples please see [examples](examples/) directory**

### Learning
Check **[learn](learn/)** directory for learning termlib.