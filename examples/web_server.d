/*
web_server.d: Live preview web server for CharBuffer 

Author : Zoda
License: MIT
Date   : 02/09/2025
*/
import termlib;
import std.stdio;
import std.socket;
import std.format;
import std.conv;
import std.string;
import std.array;
import std.path;
import core.thread;
import std.file;

string http_result(string status_code_str, string content, string content_type = "text/html"){
	return format("HTTP/1.1 %s\r\nContent-Type: %s\r\nConnection: close\r\n\r\n%s",status_code_str,content_type,content);
}
string[string] getRequestInfo(char[] buffer) {
	string[string] request;


	string request_text;
	try {
		request_text = to!string(buffer);
	} catch (Exception e) {
		return request;
	}


	string[] lines = request_text.split("\r\n");

	if (lines.length > 0) {
		string[] fline_parts = lines[0].split();
		if (fline_parts.length >= 2) {
			request["method"] = fline_parts[0];
			request["path"] = fline_parts[1];
		}
		
		// Headers
		foreach (string line; lines[1 .. $]) {
			if (line.length == 0) break;

			string[] parts = line.split(":");
			if (parts.length > 1) {
				request[parts[0].strip()] = parts[1].strip();
			}
		}
	}

	return request;
}

void backgroundTask(CharBuffer* src) {
	UPoint p;
	while (true) {
		src.fill('█');
		src.setAt(p.x, p.y, '*');
		p.x++;
		
		if (p.x >= src.width) {
			p.x = 0;
			p.y++;
		}

		if (p.y >= src.height) {
			p.y = 0;
		}

		Thread.sleep(100.msecs);
	}
}


void main() {
	CharBuffer src = new CharBuffer();
	src.setSize(50,50);

	src.fill('█');
	
	InternetAddress addr;
	TcpSocket server;

	scope(exit) {
		server.close();
		writeln("Server Closed");	
	}

	auto th = new Thread( delegate() { backgroundTask(&src); } );
	th.isDaemon = true;
	th.start();

	addr = new InternetAddress(80);
	server = new TcpSocket();
	server.bind(addr);
	server.listen(10);

	std.stdio.writeln(format("Server Started, Address: %s,Port: %s",addr.addrToString(addr.addr),addr.port));
	while (true) {
		auto client = server.accept();
		char[1024] buffer;
		auto received = client.receive(buffer[]);

		if (received <= 0) {
			client.close();
			continue;
		}

		string[string] requestInfo = getRequestInfo(buffer[0..received]);
		std.stdio.write(getColored(127,80,80,format("[%s] %s\n",requestInfo["method"], requestInfo["path"])));

		
		if (requestInfo["method"] == "GET") {
			if (requestInfo["path"] == "/") {
				client.send(http_result("200 OK", readText(buildPath(dirName(thisExePath), "assets", "index.html"))));
				client.close();
			} else if (requestInfo["path"] == "/version" ) {
				client.send(http_result("200 OK", __version__, "text/plain"));
				client.close();
			} else if (requestInfo["path"] == "/content" ) {
				string header = "HTTP/1.1 200 OK\r\n"
								~ "Content-Type: text/event-stream\r\n"
								~ "Cache-Control: no-cache\r\n"
								~ "Connection: keep-alive\r\n\r\n";
				client.send(header);

				while (true) {
					string data = "data: " ~ src.getAsString().replace("\n", "\\n") ~ "\n\n";
					client.send(data);
					Thread.sleep(200.msecs);
				}
			} else {
				client.send(http_result("404 NOT FOUND", "Nothing. (404)"));
				client.close();
			}
		}


		
	}
}
	
