import 'dart:developer' as developer;

class LogHelper {
  static String get location {
    final rawLocation = StackTrace.current.toString().split('\n')[2];
    final startIndex = rawLocation.indexOf('(');
    final endIndex = rawLocation.indexOf(')', startIndex + 1);
    final location = rawLocation.substring(startIndex + 1, endIndex);
    return location;
  }

  const LogHelper._();

  static void print(
    String message, {
    int level = 0,
    Object? error,
  }) {
    try {
      developer.log(
        message,
        time: DateTime.now(),
        error: error,
        level: level,
        name: location,
      );
    } catch (e) {
      // NOTE:
      // Don't change this code, if it is changed to above form,
      // it'll make an error when obfuscated
      developer.log(
        '$message \n Error: $e',
      );
    }
  }

  static void error(
    Object? error, {
    int level = 0,
    String? event,
  }) {
    print(
      'An error occurred ${event != null ? 'when trying to $event' : ''}',
      level: level,
      error: error,
    );
  }
}
