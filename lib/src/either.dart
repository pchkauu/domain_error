import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

const DeepCollectionEquality _eitherDeepEq = DeepCollectionEquality();

/// A value that is either an [errValue] or a [successValue].
@immutable
sealed class Either<L, R> {
  /// Whether this instance holds an error value.
  bool get isErr => this is EitherErr<L, R>;

  /// Whether this instance holds a success value.
  bool get isOk => this is EitherOk<L, R>;

  /// The error side of [Either].
  L get errValue => switch (this) {
    EitherErr(:final errValue) => errValue,
    EitherOk() => throw StateError('Either.ok has no errValue'),
  };

  /// The success side of [Either].
  R get successValue => switch (this) {
    EitherOk(:final successValue) => successValue,
    EitherErr() => throw StateError('Either.err has no successValue'),
  };

  /// Creates an [Either].
  const Either();

  /// Creates an error [Either].
  const factory Either.err(L errValue) = EitherErr<L, R>;

  /// Creates a successful [Either].
  const factory Either.ok(R successValue) = EitherOk<L, R>;

  /// Applies [ifErr] or [ifOk] depending on the held value.
  T fold<T>(
    T Function(L errValue) ifErr,
    T Function(R successValue) ifOk,
  ) {
    return switch (this) {
      EitherErr(:final errValue) => ifErr(errValue),
      EitherOk(:final successValue) => ifOk(successValue),
    };
  }

  /// Maps the success value, leaving an error unchanged.
  Either<L, R2> map<R2>(R2 Function(R successValue) transform) {
    return switch (this) {
      EitherErr(:final errValue) => Either.err(errValue),
      EitherOk(:final successValue) => Either.ok(transform(successValue)),
    };
  }
}

/// [Either] that holds an error value.
@immutable
final class EitherErr<L, R> extends Either<L, R> {
  @override
  final L errValue;

  @override
  int get hashCode => _eitherDeepEq.hash(errValue);

  /// Creates an error [Either].
  const EitherErr(this.errValue);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is EitherErr<L, R> && _eitherDeepEq.equals(other.errValue, errValue);
  }
}

/// [Either] that holds a success value.
@immutable
final class EitherOk<L, R> extends Either<L, R> {
  @override
  final R successValue;

  @override
  int get hashCode => _eitherDeepEq.hash(successValue);

  /// Creates a successful [Either].
  const EitherOk(this.successValue);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is EitherOk<L, R> && _eitherDeepEq.equals(other.successValue, successValue);
  }
}
