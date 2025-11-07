// Deprecated: logging deshabilitado. Implementación no-op en IO.

Future<void> initLogging() async {}

Future<void> logInfo(String message) async {}

Future<void> logError(Object error, [StackTrace? stackTrace]) async {}

Future<String?> logFilePath() async => null;
