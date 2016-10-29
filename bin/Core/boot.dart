import 'dart:async';

import '../routes.dart';
import 'server.dart';

class Boot {

  static strap() async {

    // Initialize routes
    var Router = new Routes();

    //Initialize server
    var s = new Server('127.0.0.1', 4040);
    await s.start(Router);

  }

}