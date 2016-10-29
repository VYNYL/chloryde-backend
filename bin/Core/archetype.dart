import 'dart:async';
import 'package:rethinkdb_driver/rethinkdb_driver.dart';

class Archetype {

  List<String> Fields;
  bool Timestamps = true;
  String Table;

  Map<String, dynamic> _fields = new Map<String, dynamic>();
  Rethinkdb _r = new Rethinkdb();

  // Allow dynamic property setting based on Fields map
  noSuchMethod(Invocation invoc) {
    if (invoc.isGetter) {
      String prop = invoc.memberName.toString();
      if (Fields.contains(prop)) {
        if (_fields.containsKey(prop)) return _fields[prop];
        return null;
      } else {
        super.noSuchMethod(invoc);
      }
    }

    if (invoc.isSetter) {
      String prop = invoc.memberName.toString().replaceAll('=', '');
      var val = invoc.positionalArguments.first;
      if (Fields.contains(val)) {
        _fields[prop] = val;
      } else {
        super.noSuchMethod(invoc);
      }
    }
  }


  // Helper function to quickly open a database connection;
  _open() {
    // TODO: Utilize environments
    return _r.connect(db: 'test', host: '127.0.0.1', port: 28015);
  }

  // Save model changes
  save() async {
    var c = _open();
    _r.table(Table).insert(_fields).run(c);
    c.close();
  }

  // Delete model
  delete() async {

  }

  // Fetch all of this model
  all() async {

  }

  sync() async {
    var c = await _open();
    return _r.table(Table).changes().run(c);
  }

}