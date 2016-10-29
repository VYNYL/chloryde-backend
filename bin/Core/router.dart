import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'archetype.dart';
import 'request.dart';

class Router {

  Map<String, Map<String, dynamic>> _routes = {
    "put": {},
    "sync": {}
  };

  Map<String, List<WebSocket>> _syncs = new Map<String, List<WebSocket>>();

  Put(String resource, Function controller) {
    _routes['put'][resource] = {
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

  // Synchronizes a socket to a resource
  // Helper function to add a websocket to the changefeed broadcast
  _sync(WebSocket ws, Request req) async {

    Map<dynamic, dynamic> r = _routes[req.action][req.resource];

    // Initialize the changefeed if it doesn't exist
    if (!_syncs.containsKey(r['archetype'].Table)) {
      _syncs[r['archetype'].Table] = [];
      _changefeed(_syncs[r['archetype'].Table], r['_controller'], await r['archetype'].sync());
    }

    if (_syncs[r['archetype'].Table].contains(ws)) return;
    _syncs[r['archetype'].Table].add(ws);
  }

  // Broadcast changes from a certain feed to a set of sockets through a controller
  _changefeed(socketlist, controller, feed) async {
    await for (var change in feed) {
      for (WebSocket ws in socketlist) {
        ws.add(controller(ws, change));
      }
    }
  }

  _wsError(message) {
    return JSON.encode({
      "error": message
    });
  }

  _handleIncoming(WebSocket ws) {
    return (msg) {
      Request req = new Request(msg, _routes);

      if (req.isValid != true) {
        ws.add(_wsError(req.isValid));
        return;
      }

      _routes[req.action][req.resource]['controller'](ws, req);

    };
  }

  subscribe(WebSocket s) {
    s.listen(_handleIncoming(s));
    print("Subscribed");
  }

}