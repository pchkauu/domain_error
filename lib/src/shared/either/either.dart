import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

const DeepCollectionEquality _eitherDeepEq = DeepCollectionEquality();

/// A value that is either a left-hand [failure] or a successful [value].
@immutable
abstract class Either<L, R> {
  /// Creates an [Either].
  const Either();

  /// Whether this instance holds a failure.
  bool get isFailure => this is EitherFailure<L, R>;

  /// Whether this instance holds a value.
  bool get isValue => this is EitherValue<L, R>;

  /// The left side of [Either], which by convention is a failure.
  L get failure => (this as EitherFailure<L, R>).failure;

  /// The right side of [Either], which by convention is a success.
  R get value => (this as EitherValue<L, R>).value;

  /// Creates a failure [Either].
  const factory Either.failure(L failure) = EitherFailure<L, R>;

  /// Creates a successful [Either].
  const factory Either.value(R value) = EitherValue<L, R>;

  /// Applies [ifFailure] or [ifValue] depending on the held value.
  T fold<T>(T Function(L failure) ifFailure, T Function(R value) ifValue) {
    if (isFailure) {
      return ifFailure(failure);
    } else {
      return ifValue(value);
    }
  }

  /// Calls [failure] or [value] with this [Either].
  void when({
    required void Function(Either<L, R> either) failure,
    required void Function(Either<L, R> either) value,
  }) {
    if (isFailure) {
      failure(this);
    } else {
      value(this);
    }
  }

  /// Maps this [Either] by calling [failure] or [value] with this instance.
  T map<T>({
    required T Function(Either<L, R> either) failure,
    required T Function(Either<L, R> either) value,
  }) {
    if (isFailure) {
      return failure(this);
    } else {
      return value(this);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return runtimeType == other.runtimeType; // ignore: no_runtimeType_toString
  }

  @override
  int get hashCode => runtimeType.hashCode; // ignore: no_runtimeType_toString
}

/// [Either] that holds a failure.
@immutable
class EitherFailure<L, R> extends Either<L, R> {
  @override
  final L failure;

  /// Creates a failure [Either].
  const EitherFailure(this.failure);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is EitherFailure<L, R> && _eitherDeepEq.equals(other.failure, failure);
  }

  @override
  int get hashCode => _eitherDeepEq.hash(failure);
}

/// [Either] that holds a value.
@immutable
class EitherValue<L, R> extends Either<L, R> {
  @override
  final R value;

  /// Creates a successful [Either].
  const EitherValue(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is EitherValue<L, R> && _eitherDeepEq.equals(other.value, value);
  }

  @override
  int get hashCode => _eitherDeepEq.hash(value);
}
