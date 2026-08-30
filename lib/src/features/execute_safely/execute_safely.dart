import 'dart:async';

import 'package:domain_error/src/entities/_barrel.dart';
import 'package:domain_error/src/shared/_barrel.dart';
import 'package:equatable/equatable.dart';

/// Runs [method] and wraps the outcome in [Result].
///
/// A successful call becomes [Either.executed]. If [method] throws:
/// - a [DomainError] is returned as [Either.domainError] after
///   [ExecuteSafelyOptions.onDomainError];
/// - any other thrown object is mapped with
///   [ExecuteSafelyOptions.mapUnexpectedToDomainError] and returned as
///   [Either.domainError].
///
/// ```dart
/// final result = await executeSafely<Order>(
///   () => loadOrder(id: id),
///   options: ExecuteSafelyOptions(
///     mapUnexpectedToDomainError: (error, stackTrace) {
///       if (error is TimeoutException) {
///         return const OrderTimeoutError();
///       } else {
///         return OrderUnavailableError(error: error, stackTrace: stackTrace);
///       }
///     },
///     onDomainError: (error, stackTrace) { /* log */ },
///     onUnexpected: (error, stackTrace) { /* log */ },
///   ),
/// );
///
/// result.fold(
///   (domainError) => print(domainError.typeIdentifier),
///   (executed) => print(executed.title),
/// );
/// ```
FutureOrResult<T> executeSafely<T>(
  FutureOr<T> Function() method, {
  required ExecuteSafelyOptions<T> options,
}) async {
  try {
    // Success: return the value as-is.
    return Either.executed(
      await method(),
    );
  } on Object catch (error, stackTrace) {
    if (error is DomainError) {
      // Expected domain error: observe it, then return the same DomainError.
      await options.onDomainError?.call(error, stackTrace);
      return Either.domainError(error);
    }

    // Unexpected throw: observe it if asked, then map to DomainError.
    await options.onUnexpected?.call(error, stackTrace);
    final domainError = await options.mapUnexpectedToDomainError(error, stackTrace);
    return Either.domainError(domainError);
  }
}

/// Options for [executeSafely].
class ExecuteSafelyOptions<T> extends Equatable {
  /// Maps an unexpected thrown object to a [DomainError].
  final FutureOr<DomainError> Function(Object error, StackTrace stackTrace) mapUnexpectedToDomainError;

  /// Observer invoked when the executed function throws a [DomainError].
  final FutureOr<void> Function(DomainError error, StackTrace stackTrace)? onDomainError;

  /// Observer invoked when the executed function throws any other object.
  final FutureOr<void> Function(Object error, StackTrace stackTrace)? onUnexpected;

  /// Creates options for [executeSafely].
  const ExecuteSafelyOptions({
    required this.mapUnexpectedToDomainError,
    this.onDomainError,
    this.onUnexpected,
  });

  @override
  List<Object?> get props => [
    mapUnexpectedToDomainError,
    onDomainError,
    onUnexpected,
  ];
}
