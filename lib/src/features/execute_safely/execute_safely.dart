import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:failure/src/entities/_barrel.dart';
import 'package:failure/src/shared/_barrel.dart';

/// Runs [method] and wraps the outcome in [Result].
///
/// A successful call becomes [Either.value]. If [method] throws:
/// - a [Failure] is returned as [Either.failure] after [ExecuteSafelyOptions.onFailure];
/// - any other error is mapped with [ExecuteSafelyOptions.mapErrorToFailure]
///   and returned as [Either.failure].
///
/// ```dart
/// final result = await executeSafely<Order>(
///   () => loadOrder(id: id),
///   options: ExecuteSafelyOptions(
///     mapErrorToFailure: (error, stackTrace) {
///       if (error is TimeoutException) {
///         return const OrderTimeoutError();
///       } else {
///         return OrderUnavailableError(error: error, stackTrace: stackTrace);
///       }
///     },
///     onFailure: (failure, stackTrace) { /* log */ },
///     onError: (error, stackTrace) { /* log */ },
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
    if (error is Failure) {
      // Expected domain failure: observe it, then return the same Failure.
      await options.onFailure?.call(error, stackTrace);
      return Either.failure(error);
    }

    // Unexpected error: observe it if asked, then map to Failure.
    await options.onError?.call(error, stackTrace);
    final failure = await options.mapErrorToFailure(error, stackTrace);
    return Either.failure(failure);
  }
}

/// Options for [executeSafely].
class ExecuteSafelyOptions<T> extends Equatable {
  /// Maps an unexpected error to a [Failure].
  final FutureOr<Failure> Function(Object error, StackTrace stackTrace) mapErrorToFailure;

  /// Observer invoked when the executed function throws a [Failure].
  final FutureOr<void> Function(Failure failure, StackTrace stackTrace)? onFailure;

  /// Observer invoked when the executed function throws any other error.
  final FutureOr<void> Function(Object error, StackTrace stackTrace)? onError;

  /// Creates options for [executeSafely].
  const ExecuteSafelyOptions({
    required this.mapErrorToFailure,
    this.onFailure,
    this.onError,
  });

  @override
  List<Object?> get props => [
    mapErrorToFailure,
    onFailure,
    onError,
  ];
}
