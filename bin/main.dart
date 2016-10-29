import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:rethinkdb_driver/rethinkdb_driver.dart';

import 'db/main.dart';

Rethinkdb db = new Rethinkdb();
StreamController<Map<dynamic, dynamic>> dbistream = new StreamController<Map<dynamic, dynamic>>();
Stream<Map<dynamic, dynamic>> dbostream;

Map<int, WebSocket> sockets = {};
ChlorydeDB d;

broadcast(Map sockets, Map<dynamic, dynamic> msg) {
  sockets.forEach((hash, sock) {
//    if (sock == sockets[fromHash]) return;
    sock.add(JSON.encode(msg));
  });
}

socketHandler(Map sockets, int fromHash, StreamController<Map<String, Map<String, String>>> dbistream) async {
  // Initialize socket
  // Fetch questions first
  List questions = d.getQuestions();

  sockets[fromHash].add(JSON.encode({
    "response": "questions",
    "text": "new questions arrived",
    "data": questions
  }));

  // Handle messages from the socket
  return (msg) {
    Map jsonMsg = JSON.decode(msg);
    print(jsonMsg);

    switch (jsonMsg['action']) {
      case 'get':
        sockets[fromHash].add(JSON.encode({"response": 'values you wanted.'}));
        break;
      case 'put':
        dbistream.add({"insert": {
          'table': 'questions',
          'fromHash': fromHash.toString(),
          'name': jsonMsg['name'],
          'title': jsonMsg['title'],
          'body': jsonMsg['body'],
          'created_at': new DateTime.now().millisecondsSinceEpoch
        }});
        break;
    }
  };
}

main() async {
  try {
    var server = await HttpServer.bind('127.0.0.1', 4041);

    d = await new ChlorydeDB("test", "127.0.0.1", 28015);
    d.subscribe(dbistream.stream, sockets);
    dbostream = d.stream;

    await for (HttpRequest req in server) {
      var socket = await WebSocketTransformer.upgrade(req);
      sockets[socket.hashCode] = socket;
      socket
          .listen(await socketHandler(sockets, socket.hashCode, dbistream))
          .onDone(() {
            sockets.remove(socket.hashCode);
            print('close');
          });
    }
  } catch (e) {
    print(e);
  }
}