/// Typed application errors mapped from network/service failures.
enum AppErrorKind {
  network,
  unauthorized,
  notFound,
  validation,
  upstream,
  conflict,
  unknown,
}

class AppException implements Exception {
  const AppException({
    required this.kind,
    required this.message,
    this.code,
    this.cause,
  });

  final AppErrorKind kind;
  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => message;
}
