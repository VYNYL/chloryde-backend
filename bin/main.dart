import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:rethinkdb_driver/rethinkdb_driver.dart';

Rethinkdb db = new Rethinkdb();

broadcast(Map sockets, int fromHash, Map<dynamic> msg) {
  sockets.forEach((hash, sock) {
//    if (sock == sockets[fromHash]) return;
    sock.add(JSON.encode(msg));
  });
}

socketHandler(connection, Map sockets, int fromHash, StreamController<Map<String, Map<String, String>>> dbStreamCtrl) async {
  // Initialize socket
  // Fetch questions first
  List questions = await db.table('questions').orderBy(db.desc('created_at')).run(connection);

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
        dbStreamCtrl.add({"insert": {
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

dbProcessIncoming(connection, Stream<Map<String, Map<String, String>>> stream, sockets) async {
  stream.listen((Map<String, Map<String, String>> res) {
    if (res.containsKey('insert')) {
      Map cmd = res['insert'];
      var table = cmd['table'];
      var fromHash = int.parse(cmd['fromHash']);
      cmd.remove('table');
      cmd.remove('from');
      db.table(table).insert(cmd).run(connection).then((e) {
        broadcast(sockets, fromHash, {
          "response": "questions",
          "text": "new questions arrived",
          "data": cmd
        });
      });
    }
  }).onDone(() => connection.close());
}

main() async {
  try {
    StreamController<Map<String, Map<String, String>>> dbStreamCtrl = new StreamController<Map<String, Map<String, String>>>();
    var server = await HttpServer.bind('127.0.0.1', 4040);
    var connection = await db.connect(db:"test", host:"127.0.0.1", port:28015);

    Map<int, WebSocket> sockets = {};

    dbProcessIncoming(connection, dbStreamCtrl.stream, sockets);

    await for (HttpRequest req in server) {
      var socket = await WebSocketTransformer.upgrade(req);
      sockets[socket.hashCode] = socket;
      socket
          .listen(await socketHandler(connection, sockets, socket.hashCode, dbStreamCtrl))
          .onDone(() {
            sockets.remove(socket.hashCode);
            print('close');
          });
    }
  } catch (e) {
    print(e);
  }
}