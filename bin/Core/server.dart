import 'dart:async';
import 'dart:io';

import '../routes.dart';

class Server {

  String host;
  int port;

  Map<int, WebSocket> _sockets = new Map<int, WebSocket>();

  Server(host, port);

  start(Router) async {
    // Initialize server
    var s = await HttpServer.bind('127.0.0.1', 4040);

    // Await connections
    await for (HttpRequest req in s) {
      // Promote http connection to websocket
      var ws = await WebSocketTransformer.upgrade(req);

      // Store connection for later use
      _sockets[ws.hashCode] = ws;

      // Route socket stream
      Router.subscribe(ws);
    }
  }
}