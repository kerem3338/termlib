/*
build.d: Build tool for termlib project.

Author : Zoda
License: MIT
Date   : 02/06/2025
*/
import std.stdio;
import std.format;
import std.path;
import std.file;
import std.algorithm;
import core.stdc.stdlib : exit, system, atexit;
import std.datetime;

// Variables for flags
long startTime;
bool getTime;

string helpText = "
Usage: %s <command> <args> ...

Commands:
	--help | help    -> Writes this message then exits.
	build-examples   -> Builds the examples.
	run-tests        -> Builds && runs unit tests
	build <filename> -> Builds the given file with termlib.d


termlib is a project by Zoda (github.com/kerem3338)
";
bool check_value_arg(string arg_name,string[] args) {
  foreach (string arg; args) {
	if (arg.startsWith(arg_name) && arg[arg_name.length] == '='){
	  return true;
	}
  }

  return false;
}

string get_value_arg(string arg_name,string[] args){
	foreach(string arg; args){
		if (arg.startsWith(arg_name) && arg[arg_name.length] == '='){
			return arg[arg_name.length + 1..$];
		}
	}
	return "";
}

bool get_arg(string arg_name,string[] args){
	foreach(string arg; args){
		if (arg == arg_name){
			return true;
		}
	}
	
	return false;
}

void writeHelp(string[] args, int exitCode = 0) {
	write(format(helpText,args[0]));
	exit(exitCode);
}

void CMD(string source, bool _exit = false) {
	writeln("[CMD]: ", source);
	int ret = system(cast(char*)source);

	if (ret != 0 && _exit) {
		exit(-1);
	}
}

extern (C) void onExit() {
	if (getTime) {
		auto endTime = Clock.currTime().toUnixTime();
		auto elapsed = cast(double)(endTime - startTime);
		writefln("\n[Elapsed %.2f seconds.]", elapsed);
	}
}


void main(string[] args) {
	atexit(&onExit);

	getTime = get_arg("-time", args);
	startTime = Clock.currTime().toUnixTime();

	if (args.length == 1) {
		writeHelp(args, 0);
	}

	

	string cmd = args[1];
	switch (cmd) {
		case "help", "--help":
			writeHelp(args, -1);
			break;
		case "build-examples":
			auto dFiles = dirEntries("examples", SpanMode.shallow).filter!(f => f.name.endsWith(".d"));
			foreach (filepath; dFiles) {
			    CMD(format("dmd termlib.d %s -of=%s", filepath, stripExtension(filepath) ~ ".exe" ), true);
			}
			break;
		case "build":
			if (args.count < 3) {
				write(format("`build` Invalid argument count: required 3 (executable, build, <filepath>), got %d", args.length));
				exit(-2);
			}

			string filepath = args[2];
			if (!exists(filepath) || !isFile(filepath)) {
				write(format("`build` Given filepath (`%s`) not exists or not a file.", filepath));
				exit(-3);
			}


			CMD(format("dmd termlib.d %s -of=%s", filepath, stripExtension(filepath) ~ ".exe" ), true);
			break;
		case "run-tests":
			CMD("dmd termlib.d -unittest -main -of=termlib.exe");
			CMD("termlib.exe");
			break;
		default:
			write("Invalid command. \n");
			writeHelp(args, -1);
			break;
	}
}