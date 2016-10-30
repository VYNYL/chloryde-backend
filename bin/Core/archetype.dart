import 'dart:async';
import 'package:rethinkdb_driver/rethinkdb_driver.dart';

class Archetype {

  List<String> Fields;
  bool Timestamps = true;
  String Table;

  Map<String, dynamic> _fields = {};
  Rethinkdb _r = new Rethinkdb();

  operator [](String i) {
    if (Fields.contains(i) && _fields.containsKey(i)) return _fields[i];
    return null;
  }

  operator []=(String i, dynamic value) {
    if (Fields.contains(i)) {
      return _fields[i] = value;
    }
    return null;
  }

  // Helper function to quickly open a database connection;
  _open() {
    // TODO: Utilize environments
    return _r.connect(db: 'test', host: '127.0.0.1', port: 28015);
  }

  populate(data) {
    data.forEach((k, v) {
      if (Fields.contains(k)) this[k] = v;
    });
  }

  // Save model changes
  save() async {
    var c = await _open();
    print(_fields);
    if (Timestamps) _fields['created_at'] = new DateTime.now().millisecondsSinceEpoch;
    await _r.table(Table).insert(_fields).run(c);
    c.close();
  }

  // Delete model
  delete() async {

  }

  // Fetch all of this model
  all() async {
    var c = await _open();
    var vals = await _r.table(Table).orderBy(_r.desc('id')).run(c);
    c.close();
    return vals;
  }

  sync() async {
    var c = await _open();
    return _r.table(Table).changes().run(c);
  }

}