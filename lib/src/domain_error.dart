import 'package:equatable/equatable.dart';

/// Expected domain or application error.
///
/// Feature error roots extend [DomainError] in their own libraries. Keep this
/// type as an `abstract class` so those roots can live outside this file.
///
/// [typeIdentifier] stays stable after obfuscation and is the primary label
/// for logs and error reporting.
abstract class DomainError extends Equatable implements Exception {
  /// Stable identifier of the concrete error type.
  ///
  /// Used to display the error after obfuscation, for example in Sentry.
  /// Example: `typeIdentifier => 'SignatureError'`.
  String get typeIdentifier;

  /// Optional human-readable description.
  final String? message;

  /// Optional technical cause.
  final Object? rawError;

  /// Optional stack trace of the technical cause.
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [
    typeIdentifier,
    message,
    rawError,
    stackTrace,
  ];

  String? get _stableDetail {
    final normalizedMessage = message?.trim();
    if (normalizedMessage != null && normalizedMessage.isNotEmpty) {
      return normalizedMessage;
    }

    final cause = rawError;
    if (cause == null) {
      return null;
    }
    if (cause is DomainError) {
      return cause.typeIdentifier;
    }

    final description = cause.toString().trim();
    if (description.isEmpty || description.startsWith('Instance of ')) {
      return 'unknown';
    }
    return description.split('\n').first.trim();
  }

  /// Creates a [DomainError].
  const DomainError({
    this.message,
    this.rawError,
    this.stackTrace,
  });

  @override
  String toString() {
    final detail = _stableDetail;
    if (detail == null || detail.isEmpty) {
      return typeIdentifier;
    }
    return '$typeIdentifier($detail)';
  }
}
