import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiUrl => dotenv.env['API_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  static Future<void> initEnvironment() async {
    await dotenv.load(fileName: ".env");
  }
}
