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

  static GetQuestion(Request req) async {
    Question qs = new Question();
    var questions = await qs.all();

    Map response = {};

    response['action'] = 'get';
    response['resource'] = 'questions';
    response['data'] = questions;

    req.socket.add(JSON.encode(response));
  }

  static PutQuestion(Request req) async {

    Question q = new Question();

    var isValid = await q.validate(req.data);
    if (!isValid) {
      req.socket.add(JSON.encode({
        "error": "Invalid question format"
      }));
      return;
    }

    q.populate(req.data);

    await q.save();

  }

  static DeleteQuestion(Request req) async {
    Question q = new Question();
    await q.delete(req.data['id']);
  }

}