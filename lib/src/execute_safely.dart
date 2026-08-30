import 'dart:async';

import 'package:domain_error/src/domain_error.dart';
import 'package:domain_error/src/either.dart';
import 'package:domain_error/src/result.dart';

/// Runs [method] and wraps the outcome in [Result].
///
/// A successful call becomes [Either.ok]. If [method] throws:
/// - a [DomainError] is returned as [Either.err] after
///   [ExecuteSafelyOptions.onDomainError];
/// - any other thrown object is mapped with
///   [ExecuteSafelyOptions.mapRawErrorToDomain] and returned as
///   [Either.err].
///
/// ```dart
/// final result = await executeSafely<Order>(
///   () => loadOrder(id: id),
///   options: ExecuteSafelyOptions(
///     mapRawErrorToDomain: (rawError, stackTrace) {
///       if (rawError is TimeoutException) {
///         return const OrderTimeoutError();
///       } else {
///         return OrderUnavailableError(rawError: rawError, stackTrace: stackTrace);
///       }
///     },
///     onDomainError: (domainError, stackTrace) { /* log */ },
///     onRawError: (rawError, stackTrace) { /* log */ },
///   ),
/// );
///
/// result.fold(
///   (domainError) => print(domainError.typeIdentifier),
///   (successValue) => print(successValue.title),
/// );
/// ```
Future<Result<T>> executeSafely<T>(
  FutureOr<T> Function() method, {
  required ExecuteSafelyOptions options,
}) async {
  try {
    return Either.ok(
      await method(),
    );
  } on Object catch (error, stackTrace) {
    if (error is DomainError) {
      await options.onDomainError?.call(error, stackTrace);
      return Either.err(error);
    }

    await options.onRawError?.call(error, stackTrace);
    final domainError = await options.mapRawErrorToDomain(error, stackTrace);
    return Either.err(domainError);
  }
}

/// Runs [method] synchronously and wraps the outcome in [Result].
///
/// A successful call becomes [Either.ok]. If [method] throws:
/// - a [DomainError] is returned as [Either.err] after
///   [ExecuteSafelySyncOptions.onDomainError];
/// - any other thrown object is mapped with
///   [ExecuteSafelySyncOptions.mapRawErrorToDomain] and returned as
///   [Either.err].
///
/// ```dart
/// final result = executeSafelySync<Order>(
///   () => loadOrder(id: id),
///   options: ExecuteSafelySyncOptions(
///     mapRawErrorToDomain: (rawError, stackTrace) {
///       if (rawError is TimeoutException) {
///         return const OrderTimeoutError();
///       } else {
///         return OrderUnavailableError(rawError: rawError, stackTrace: stackTrace);
///       }
///     },
///     onDomainError: (domainError, stackTrace) { /* log */ },
///     onRawError: (rawError, stackTrace) { /* log */ },
///   ),
/// );
///
/// result.fold(
///   (domainError) => print(domainError.typeIdentifier),
///   (successValue) => print(successValue.title),
/// );
/// ```
Result<T> executeSafelySync<T>(
  T Function() method, {
  required ExecuteSafelySyncOptions options,
}) {
  try {
    return Either.ok(
      method(),
    );
  } on Object catch (error, stackTrace) {
    if (error is DomainError) {
      options.onDomainError?.call(error, stackTrace);
      return Either.err(error);
    }

    options.onRawError?.call(error, stackTrace);
    final domainError = options.mapRawErrorToDomain(error, stackTrace);
    return Either.err(domainError);
  }
}

/// Options for [executeSafely].
class ExecuteSafelyOptions {
  /// Maps an unexpected thrown object to a [DomainError].
  final FutureOr<DomainError> Function(Object rawError, StackTrace stackTrace) mapRawErrorToDomain;

  /// Observer invoked when the executed function throws a [DomainError].
  final FutureOr<void> Function(DomainError domainError, StackTrace stackTrace)? onDomainError;

  /// Observer invoked when the executed function throws any other object.
  final FutureOr<void> Function(Object rawError, StackTrace stackTrace)? onRawError;

  /// Creates options for [executeSafely].
  const ExecuteSafelyOptions({
    required this.mapRawErrorToDomain,
    this.onDomainError,
    this.onRawError,
  });
}

/// Options for [executeSafelySync].
class ExecuteSafelySyncOptions {
  /// Maps an unexpected thrown object to a [DomainError].
  final DomainError Function(Object rawError, StackTrace stackTrace) mapRawErrorToDomain;

  /// Observer invoked when the executed function throws a [DomainError].
  final void Function(DomainError domainError, StackTrace stackTrace)? onDomainError;

  /// Observer invoked when the executed function throws any other object.
  final void Function(Object rawError, StackTrace stackTrace)? onRawError;

  /// Creates options for [executeSafelySync].
  const ExecuteSafelySyncOptions({
    required this.mapRawErrorToDomain,
    this.onDomainError,
    this.onRawError,
  });
}
