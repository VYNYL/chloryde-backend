import 'dart:async';
import './db.dart';
import 'package:json_schema/json_schema.dart' as Scheme;

class Archetype {

  List<String> Fields;
  bool Timestamps = true;
  String Table;

  Map<String, dynamic> _fields = {};

  var Schema = false;

  Future<bool> validate(val) async {
    if (Schema == false) return true;
    var s = await Scheme.Schema.createSchema(Schema);
    return s.validate(val);
  }

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
  _open() async {
    // TODO: Utilize environments
    var c = await db.connect();
    return c;
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
    await db.r.table(Table).insert(_fields).run(c);
    c.close();
  }

  // Delete model
  delete() async {

  }

  // Fetch all of this model
  all() async {
    var c = await _open();
    var vals = await db.r.table(Table).orderBy(db.r.desc('id')).run(c);
    c.close();
    return vals;
  }

  sync() async {
    var c = await _open();
    return db.r.table(Table).changes().run(c);
  }

}