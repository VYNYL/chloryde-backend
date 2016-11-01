import 'dart:io';
import 'dart:convert';
import '../Core/request.dart';
import '../Models/model.question.dart';

class CtrlQuestion {

  static SyncQuestion(WebSocket ws, req) {

    Map response = {};

    response['action'] = 'sync';
    response['resource'] = 'questions';
    response['data'] = req;

    ws.add(JSON.encode(response));
  }

  static GetQuestion(WebSocket ws, Request req) async {
    Question qs = new Question();
    var questions = await qs.all();

    Map response = {};

    response['action'] = 'get';
    response['resource'] = 'questions';
    response['data'] = questions;

    ws.add(JSON.encode(response));
  }

  static PutQuestion(WebSocket ws, Request req) async {

    Question q = new Question();

    var isValid = await q.validate(req.data);
    if (!isValid) {
      ws.add(JSON.encode({
        "error": "Invalid question format"
      }));
      return;
    }

    q.populate(req.data);

    await q.save();

  }

}