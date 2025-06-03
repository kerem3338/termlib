# Getting Started With Termlib

As mentioned in [README.md](../README.md) you can compile your own program file with `build.exe` tool or you can use `dmd termlib.d <your_filename.d> -of=<your_output_name>.exe` command.

## Creating A Buffer

Well before get started first you need to create very basic D program like following.

```d
import termlib;
import std.stdio;

void main() {
	...
} 
```

Then you need to create a `CharBuffer` object. like following.

```d
CharBuffer buffer;
```

Alright we now created the buffer, now we need to set size of buffer (setting up the actual buffer data).

```d
buffer.setSize(25, 25);
```

Cool, but nobody likes empty buffers here, so lets fill it with something else...

```d
buffer.fill('#');
```

To write buffer content to console you can use `getAsString` method.

```d
write(buffer.getAsString());
```

### Final Source

```d
import termlib;
import std.stdio;

void main() {
	CharBuffer buffer;
	buffer.setSize(25, 25);
	buffer.fill('#');
	write(buffer.getAsString());
}
```

Using termlib is that simple.