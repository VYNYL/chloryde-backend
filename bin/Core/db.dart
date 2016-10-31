import 'package:rethinkdb_driver/rethinkdb_driver.dart';
import '../migrate.dart';

class db {

  static Rethinkdb r = new Rethinkdb();

  static connect({migrate: false}) async {

    var c = await r.connect(db: 'rethinkdb', host: 'rethinkdb', port: 28015);

    if (!migrate) {
      c.use(Migrate.Database);
    }

    return c;

  }

}