import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'archetype.dart';
import 'request.dart';

class Router {

  Map<String, Map<String, dynamic>> _routes = {
    "put": {},
    "sync": {},
    "desync": {},
    "get": {},
    "delete": {}
  };

  Map<String, List<WebSocket>> _syncs = new Map<String, List<WebSocket>>();

  Get(String resource, Function controller) {
    _routes['get'][resource] = {
      "controller": controller
    };
  }

  Put(String resource, Function controller) {
    _routes['put'][resource] = {
      "controller": controller
    };
  }

  Delete(String resource, Function controller) {
    _routes['delete'][resource] = {
      "controller": controller
    };
  }

  Sync(String resource, Function controller, Archetype a) {
    _routes['sync'][resource] = {
      "controller": _sync,
      "_controller": controller,
      "archetype": a
    };
  }

  Desync(String resource, Function controller, Archetype a) {

  }

  // Synchronizes a socket to a resource
  // Helper function to add a websocket to the changefeed broadcast
  _sync(Request req) async {

    Map<dynamic, dynamic> r = _routes[req.action][req.resource];

    // Initialize the socketlist if it doesn't exist
    if (!_syncs.containsKey(r['archetype'].Table)) {
      _syncs[r['archetype'].Table] = [];
    }

    // If there are no sockets in the socketlist, then initialize the changefeed
    if (_syncs[r['archetype'].Table].length <= 0) {
      _changefeed(_syncs[r['archetype'].Table], r['_controller'], await r['archetype'].sync());
    }

    // Skip existing sync connections
    if (_syncs[r['archetype'].Table].contains(req.socket)) return;

    _syncs[r['archetype'].Table].add(req.socket);
  }

  // Broadcast changes from a certain feed to a set of sockets through a controller
  _changefeed(List<WebSocket> socketlist, controller, Stream<dynamic> feed) async {
    await for (var change in feed) {
      var stale = [];
      for (WebSocket ws in socketlist) {

        // Prepare to trim out stale connections
        if (ws.readyState == WebSocket.CLOSING || ws.readyState == WebSocket.CLOSED) {
          stale.add(ws);
          continue;
        }

        print("Sync update");
        controller(ws, change);
      }
      // Remove stale connections
      for (var connection in stale) {
        socketlist.remove(connection);
      }

      // No more sockets, close changefeed
      if (socketlist.length <= 0) return;
    }
  }

  _wsError(message) {
    return JSON.encode({
      "error": message
    });
  }

  _handleIncoming(WebSocket ws) {
    return (msg) {
      Request req = new Request(msg, ws, _routes);



      if (req.isValid != true) {
        ws.add(_wsError(req.isValid));
        return;
      }

      _routes[req.action][req.resource]['controller'](req);

    };
  }

  subscribe(WebSocket s) {
    s.listen(_handleIncoming(s));
    print("Subscribed");
  }

}