import 'dart:async';

import '../routes.dart';
import 'db.dart';
import 'server.dart';

import '../migrate.dart';

class Boot {

  static strap() async {

    // Initialize routes
    var Router = new Routes();

    var c = await db.connect(migrate: true);

    var hasdb = await db.r.dbList().contains(Migrate.Database).run(c);
    if (!hasdb) await db.r.dbCreate(Migrate.Database).run(c);

    c.use(Migrate.Database);

    for (var Table in Migrate.Tables) {
      var hasTable = await db.r.tableList().contains(Table).run(c);
      if (!hasTable) await db.r.tableCreate(Table).run(c);
    }

    //Initialize server
    var s = new Server('127.0.0.1', 4040);
    await s.start(Router);

  }

}