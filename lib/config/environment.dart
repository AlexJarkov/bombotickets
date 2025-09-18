import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiUrl => dotenv.env['API_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  
  static String get token => dotenv.env['TOKEN'] ?? '';

  static Future<void> initEnvironment() async {
    await dotenv.load(fileName: ".env");
    log("apiUrl: $apiUrl");
    log("apiKey: $apiKey");
    log("token:$token");
  }
}
