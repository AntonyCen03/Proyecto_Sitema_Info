// Deprecated: logging deshabilitado a solicitud del usuario.
// Todas las funciones son no-op.

Future<void> initLogging() async {}

Future<void> logInfo(String message) async {}

Future<void> logError(Object error, [StackTrace? stackTrace]) async {}

Future<String?> logFilePath() async => null;
