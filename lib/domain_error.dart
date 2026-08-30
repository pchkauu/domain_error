/// Domain errors and helpers for handling them.
///
/// Start with `DomainError`, fold outcomes with `Either` or `Result`, and
/// convert thrown errors through `executeSafely` or `executeSafelySync`.
library;

export 'src/domain_error.dart';
export 'src/either.dart';
export 'src/execute_safely.dart';
export 'src/result.dart';
