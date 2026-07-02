/// Domain-level failure for orchestration layers to surface user-facing errors.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

final class ScanNotAllowedException extends AppException {
  const ScanNotAllowedException(super.message);
}

final class PersistenceException extends AppException {
  const PersistenceException(super.message);
}

final class ValidationException extends AppException {
  const ValidationException(super.message);
}
