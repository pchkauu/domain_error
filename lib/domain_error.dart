/// Domain errors and helpers for handling them.
///
/// Start with `DomainError`, fold outcomes with `Either` or `Result`, and
/// convert thrown errors through `captureResult` or `captureResultSync`.
library;

export 'src/capture_result.dart';
export 'src/domain_error.dart';
export 'src/either.dart';
export 'src/result.dart';
