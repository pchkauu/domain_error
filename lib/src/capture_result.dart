import 'dart:async';

import 'package:domain_error/src/domain_error.dart';
import 'package:domain_error/src/either.dart';
import 'package:domain_error/src/result.dart';

/// Runs [operation] and captures its outcome in a [Result].
///
/// A successful call becomes [Either.success]. A thrown [DomainError] becomes
/// [Either.error] with the same instance after [CaptureResultOptions.onDomainError].
/// Any other thrown object is observed by [CaptureResultOptions.onRawError],
/// then converted by [CaptureResultOptions.mapToDomainError]. The mapped error
/// does not trigger [CaptureResultOptions.onDomainError].
///
/// Awaits the operation, observers, observer error handler, and mapper in order.
/// Observer failures never replace the result. Mapper failures propagate with
/// their original stack trace; they are not passed to an observer.
Future<Result<T>> captureResult<T>(
  FutureOr<T> Function() operation, {
  required CaptureResultOptions options,
}) async {
  try {
    return Either.success(await operation());
  } on Object catch (error, stackTrace) {
    if (error is DomainError) {
      await _observe(options.onDomainError, error, stackTrace, options.onObserverError);
      return Either.error(error);
    }

    await _observe(options.onRawError, error, stackTrace, options.onObserverError);
    final domainError = await options.mapToDomainError(error, stackTrace);
    return Either.error(domainError);
  }
}

/// Runs [operation] synchronously and captures its outcome in a [Result].
///
/// Uses the same error routing as [captureResult], without awaiting callbacks.
/// The operation, mapper, and every observer must be synchronous. Passing async
/// callbacks to a `void` observer is unsupported: their futures are not awaited
/// and their asynchronous failures are not captured. Use [captureResult] for
/// asynchronous work; this function provides no static or runtime rejection.
///
/// Observer failures never replace the result. Mapper failures propagate with
/// their original stack trace.
Result<T> captureResultSync<T>(
  T Function() operation, {
  required CaptureResultSyncOptions options,
}) {
  try {
    return Either.success(operation());
  } on Object catch (error, stackTrace) {
    if (error is DomainError) {
      _observeSync(options.onDomainError, error, stackTrace, options.onObserverError);
      return Either.error(error);
    }

    _observeSync(options.onRawError, error, stackTrace, options.onObserverError);
    final domainError = options.mapToDomainError(error, stackTrace);
    return Either.error(domainError);
  }
}

/// Options for [captureResult].
class CaptureResultOptions {
  /// Converts a non-domain thrown object. Failures from this mapper propagate.
  final FutureOr<DomainError> Function(Object rawError, StackTrace stackTrace) mapToDomainError;

  /// Observes an original thrown [DomainError], before returning that same error.
  final FutureOr<void> Function(DomainError domainError, StackTrace stackTrace)? onDomainError;

  /// Observes any other thrown object before [mapToDomainError] runs.
  final FutureOr<void> Function(Object rawError, StackTrace stackTrace)? onRawError;

  /// Reports a failure of [onDomainError] or [onRawError], with its stack trace.
  ///
  /// When absent, observer failures are ignored. Failures of this handler are
  /// also ignored, without recursion, so reporting cannot replace the result.
  final FutureOr<void> Function(Object observerError, StackTrace stackTrace)? onObserverError;

  /// Creates options for [captureResult].
  const CaptureResultOptions({
    required this.mapToDomainError,
    this.onDomainError,
    this.onRawError,
    this.onObserverError,
  });
}

/// Synchronous options for [captureResultSync].
///
/// All callbacks must complete synchronously. Async observers are unsupported;
/// use [CaptureResultOptions] and [captureResult] when a callback returns a future.
class CaptureResultSyncOptions {
  /// Converts a non-domain thrown object. Failures from this mapper propagate.
  final DomainError Function(Object rawError, StackTrace stackTrace) mapToDomainError;

  /// Observes an original thrown [DomainError], before returning that same error.
  final void Function(DomainError domainError, StackTrace stackTrace)? onDomainError;

  /// Observes any other thrown object before [mapToDomainError] runs.
  final void Function(Object rawError, StackTrace stackTrace)? onRawError;

  /// Reports a synchronous failure of [onDomainError] or [onRawError].
  ///
  /// When absent, observer failures are ignored. Synchronous failures of this
  /// handler are also ignored, without recursion, preserving the result.
  final void Function(Object observerError, StackTrace stackTrace)? onObserverError;

  /// Creates options for [captureResultSync].
  const CaptureResultSyncOptions({
    required this.mapToDomainError,
    this.onDomainError,
    this.onRawError,
    this.onObserverError,
  });
}

Future<void> _observe<T>(
  FutureOr<void> Function(T error, StackTrace stackTrace)? observer,
  T error,
  StackTrace stackTrace,
  FutureOr<void> Function(Object observerError, StackTrace stackTrace)? onObserverError,
) async {
  if (observer == null) {
    return;
  }
  try {
    await observer(error, stackTrace);
  } on Object catch (observerError, observerStackTrace) {
    try {
      await onObserverError?.call(observerError, observerStackTrace);
    } on Object {
      // Reporting must never replace the operation's result or recurse.
    }
  }
}

void _observeSync<T>(
  void Function(T error, StackTrace stackTrace)? observer,
  T error,
  StackTrace stackTrace,
  void Function(Object observerError, StackTrace stackTrace)? onObserverError,
) {
  if (observer == null) {
    return;
  }
  try {
    observer(error, stackTrace);
  } on Object catch (observerError, observerStackTrace) {
    try {
      onObserverError?.call(observerError, observerStackTrace);
    } on Object {
      // Reporting must never replace the operation's result or recurse.
    }
  }
}
