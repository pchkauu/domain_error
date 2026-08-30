import 'dart:async';

import 'package:domain_error/src/entities/_barrel.dart';
import 'package:domain_error/src/shared/_barrel.dart';
import 'package:equatable/equatable.dart';

/// Runs [method] and wraps the outcome in [Result].
///
/// A successful call becomes [Either.value]. If [method] throws:
/// - a [DomainError] is returned as [Either.failure] after [ExecuteSafelyOptions.onError];
/// - any other thrown object is mapped with [ExecuteSafelyOptions.mapThrownToError]
///   and returned as [Either.failure].
///
/// ```dart
/// final result = await executeSafely<Order>(
///   () => loadOrder(id: id),
///   options: ExecuteSafelyOptions(
///     mapThrownToError: (error, stackTrace) {
///       if (error is TimeoutException) {
///         return const OrderTimeoutError();
///       } else {
///         return OrderUnavailableError(error: error, stackTrace: stackTrace);
///       }
///     },
///     onError: (error, stackTrace) { /* log */ },
///     onThrown: (error, stackTrace) { /* log */ },
///   ),
/// );
///
/// result.fold(
///   (failure) => print(failure.typeIdentifier),
///   (value) => print(value.title),
/// );
/// ```
FutureOrResult<T> executeSafely<T>(
  FutureOr<T> Function() method, {
  required ExecuteSafelyOptions<T> options,
}) async {
  try {
    // Success: return the value as-is.
    return Either.value(
      await method(),
    );
  } on Object catch (error, stackTrace) {
    if (error is DomainError) {
      // Expected domain error: observe it, then return the same DomainError.
      await options.onError?.call(error, stackTrace);
      return Either.failure(error);
    }

    // Unexpected throw: observe it if asked, then map to DomainError.
    await options.onThrown?.call(error, stackTrace);
    final domainError = await options.mapThrownToError(error, stackTrace);
    return Either.failure(domainError);
  }
}

/// Options for [executeSafely].
class ExecuteSafelyOptions<T> extends Equatable {
  /// Maps an unexpected thrown object to a [DomainError].
  final FutureOr<DomainError> Function(Object error, StackTrace stackTrace) mapThrownToError;

  /// Observer invoked when the executed function throws a [DomainError].
  final FutureOr<void> Function(DomainError error, StackTrace stackTrace)? onError;

  /// Observer invoked when the executed function throws any other object.
  final FutureOr<void> Function(Object error, StackTrace stackTrace)? onThrown;

  /// Creates options for [executeSafely].
  const ExecuteSafelyOptions({
    required this.mapThrownToError,
    this.onError,
    this.onThrown,
  });

  @override
  List<Object?> get props => [
    mapThrownToError,
    onError,
    onThrown,
  ];
}
