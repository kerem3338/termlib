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
import std.array;
// Variables for flags
MonoTime startTime;
bool getTime;
bool noSkip = false;
bool quite = false;
bool noTermlib = false;
string compiler = "dmd";
string[] sourceFiles = [];

// IMPORTANT
mixin("string versionId = \""~__TIMESTAMP__~"\";");

string[] ignored_examples = [
	"arsd_simpledisplay.d" // Reason: needs external dependencies
];

string helpText = "
Usage: %s <command> <args> ...

Commands:
	--help | help            -> Writes this message then exits
	build-examples           -> Builds the examples
	run-tests                -> Builds && runs unit tests
	build <filename>         -> Builds the given file with termlib.d
	build-example <filename> -> Builds a single example
	fix-win                  -> executes `chcp 65001` command
	ignored-examples         -> Lists all examples ignored by `build-examples` by default
	version                  -> Prints executable version ID
	arsd-terminal <path>     -> Downloads arsd.terminal and arsd.core

Flags etc.:
	-time            -> Records elapsed time to execute the command
	-noskip          -> Don't skip ignored examples
	-quite           -> Don't print things that are not too important
	--compiler=<...> -> Change selected compiler (default: dmd)
	--sources=<...>  -> Additional source files for compiler (seperated by comma)
	-no-termlib      -> Remove termlib.d from sources
	
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
	write(format(helpText, baseName(args[0])));
	exit(exitCode);
}

int CMD(string source, bool _exit = false) {
	writeln("[CMD]: ", source);
	int ret = system(cast(char*)source);

	if (ret != 0 && _exit) {
		exit(-1);
	}

	return ret;
}

extern (C) void onExit() {
	if (getTime) {
		auto ms = (MonoTime.currTime - startTime).total!"msecs";

		writefln("\n[\033[3mElapsed: %dm, %ds, %dms\033[23m]", ms / 60000, (ms % 60000) / 1000, ms % 1000);
	}
}

string getSourceFiles() {
	return sourceFiles.join(" ");
}

/*
arsd.terminal is good for reading UTF-8 chars from terminal, currently termlib can't do that.
*/
void downloadArsdTerminal(string basePath) {
	CMD(format("curl https://raw.githubusercontent.com/adamdruppe/arsd/refs/heads/master/terminal.d -o %s", buildPath(basePath, "terminal.d")), true);
	CMD(format("curl https://raw.githubusercontent.com/adamdruppe/arsd/refs/heads/master/core.d -o %s", buildPath(basePath, "core.d")), true);
}

void main(string[] args) {
	atexit(&onExit);

	sourceFiles = [relativePath(buildPath(dirName(thisExePath),"termlib.d"))];

	string compilerArg = get_value_arg("--compiler", args);
	string sourcesArg  = get_value_arg("--sources", args);
	getTime = get_arg("-time", args);
	noSkip  = get_arg("-noskip", args);
	quite   = get_arg("-quite", args);
	noTermlib = get_arg("-no-termlib", args);
	startTime = MonoTime.currTime;

	if (args.length == 1) {
		writeHelp(args, 0);
	}

	if (noTermlib) {
		sourceFiles = [];
	}

	if (compilerArg != "") {
		compiler = compilerArg;
	}

	if (sourcesArg != "") {
		sourceFiles ~= sourcesArg.split(",");
	}


	string cmd = args[1];
	switch (cmd) {
		case "help", "--help":
			writeHelp(args, -1);
			break;

		case "build-examples":
			auto examplesDir = dirEntries("examples", SpanMode.shallow).filter!(f => f.name.endsWith(".d"));
			foreach (filepath; examplesDir) {
					if (ignored_examples.canFind(baseName(filepath)) && !noSkip) {
						writeln(format("[INF]: Skipped example: %s", filepath));
						continue;
					}
			    CMD(format("%s %s %s -of=%s", compiler, getSourceFiles(), filepath, stripExtension(filepath) ~ ".exe" ), true);
			}
			break;

		case "build-example":
			auto examplesDir = dirEntries("examples", SpanMode.shallow).filter!(f => f.name.endsWith(".d"));
			if (args.count < 3) {
				write(format("`build-example` Invalid argument count: required 3 (executable, build-example, <filepath>), got %d", args.length));
				exit(-2);
			}

			string filename = args[2];
			string filepath = buildPath("examples", filename);

			if (!exists(filepath) || !isFile(filepath)) {
				write(format("`build-example` Given filepath (`%s`) not exists or not a file.", filepath));
				exit(-3);
			}

			CMD(format("%s %s %s -of=%s", compiler, getSourceFiles(), filepath, stripExtension(filepath) ~ ".exe" ), true);
			break;

		case "ignored-examples":
			foreach(string example_name; ignored_examples) {
				writeln(example_name);
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


			CMD(format("%s %s %s -of=%s", compiler, getSourceFiles(), filepath, stripExtension(filepath) ~ ".exe" ), true);
			break;

		case "version":
			if (!quite) {
				write("build.d Executable Version ID:\n\t"); 
			}
			writeln(versionId);
			break;

		case "run-tests":
			CMD(format("%s termlib.d -unittest -main -of=termlib.exe", compiler));
			version (Windows) {
				CMD("termlib.exe");
			} else { CMD("./termlib.exe"); }
			break;

		case "arsd-terminal":
			string basePath = dirName(thisExePath);
			if(args.length >= 3) {
				basePath = args[2];
			}
			downloadArsdTerminal(basePath);
			break;
		case "fix-win":
			CMD("chcp 65001");
			break;

		default:
			if (quite) break;
			write("Invalid command. \n");
			writeHelp(args, -1);
			break;
	}
}