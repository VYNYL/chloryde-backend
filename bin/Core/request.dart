import 'dart:convert';
import 'dart:io';

class Request {

  static final ERROR_REQUEST_INVALID_ACTION = "error_request_invalid_action";
  static final ERROR_REQUEST_INVALID_RESOURCE = "error_request_invalid_resource";
  static final ERROR_REQUEST_INVALID_REQUEST = "error_request_invalid_request";
  static final ERROR_REQUEST_INVALID_JSON = "error_request_invalid_json";

  String action;
  String resource;
  Map<dynamic, dynamic> data;
  String raw;

  WebSocket socket;

  dynamic _valid = false;
  dynamic get isValid => _valid;

  Map<dynamic, dynamic> _routes;

  _validate(req, _routes) {
    // Ensure properly formatted request
    if (!req.containsKey('route')) return ERROR_REQUEST_INVALID_REQUEST;

    Map reqRoute = req['route'];

    if (!reqRoute.containsKey('resource') || !reqRoute.containsKey('action')) return ERROR_REQUEST_INVALID_REQUEST;

    String resource = reqRoute['resource'];
    String action = reqRoute['action'];

    // Validate incoming action
    if (!_routes.containsKey(action)) return ERROR_REQUEST_INVALID_ACTION;

    // Validate resource against action
    if (!_routes[action].containsKey(resource)) return ERROR_REQUEST_INVALID_RESOURCE;

    return true;
  }

  Request(String _req, WebSocket socket, Map<dynamic, dynamic>_routes) {
    Map req;
    this.socket = socket;

    try {
      raw = _req;
      req = JSON.decode(_req);
    } catch (e) {
      _valid = ERROR_REQUEST_INVALID_JSON;
      return;
    }

    var validate = _validate(req, _routes);
    _valid = validate;

    if (validate != true) return;

    Map reqRoute = req['route'];
    if (req.containsKey('data')) data = req['data'];

    action = reqRoute['action'];
    resource = reqRoute['resource'];

  }

}