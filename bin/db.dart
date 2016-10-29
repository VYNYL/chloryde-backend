import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:rethinkdb_driver/rethinkdb_driver.dart';

Rethinkdb db = new Rethinkdb();

class ChlorydeDB {

  Rethinkdb r = new Rethinkdb();
  Connection c;
  StreamController<Map<dynamic, dynamic>> dbostream;

  Stream get stream => dbostream.stream;

  ChlorydeDB(dbname, hostname, port) {
    db.connect(db: dbname, host: hostname, port: port).then((val) => c = val);
    dbostream = new StreamController<Map<dynamic, dynamic>>();
  }

  subscribe(
    Stream<Map<String, Map<String, String>>> istream) async {
    await for (Map<String, Map<String, String>> res in stream) {
      if (res.containsKey('insert')) {
        Map cmd = res['insert'];
        var table = cmd['table'];
        var fromHash = int.parse(cmd['fromHash']);
        cmd.remove('table');
        cmd.remove('from');
        db.table(table).insert(cmd).run(c).then((e) {

        });
      }
    }
    c.close();
  }

  listen() {

  }

  getQuestions() {
    return r.table('questions').orderBy(db.desc('created_at')).run(connection);
  }

}