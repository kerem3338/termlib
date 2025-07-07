import termlib;
import std.stdio;
import std.format;
import core.thread: Thread;
import std.datetime: msecs;

void main() {
   fixWindows();
   ColoredBuffer buffer = new ColoredBuffer();
   Size termSize = getConsoleSize();

   buffer.setSize(termSize.w, termSize.h);
   buffer.fill(' ');
   char ch;

   hideCursor();
   while (ch != 'q') {
      termSize = getConsoleSize();

      buffer.setSize(termSize.w, termSize.h);
      buffer.fill(' ');
      buffer.writeC(format("Terminal Size (%d,%d)",termSize.w, termSize.h));

      setCursorPositionOS(0,0);
      write(buffer.getAsColored());
      
      if (kbhit() != 0) {
         ch = cast(char) getch();
      }

      Thread.sleep(50.msecs);
   }
   showCursor();
}