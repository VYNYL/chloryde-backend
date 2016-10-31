import 'dart:io';
import 'dart:async';
import 'Core/boot.dart';

main() async {
  try {

    print("Listening in server");
    // Initialize application
    await Boot.strap();

  } catch (e) {
    print(e);
  }
}