import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

const DeepCollectionEquality _eitherDeepEq = DeepCollectionEquality();

/// A value that is either a left-hand [domainError] or a successful [executed].
@immutable
abstract class Either<L, R> {
  /// Creates an [Either].
  const Either();

  /// Whether this instance holds a domain error.
  bool get isFailed => this is EitherDomainError<L, R>;

  /// Whether this instance holds an executed value.
  bool get isExecuted => this is EitherExecuted<L, R>;

  /// The left side of [Either], which by convention is a domain error.
  L get domainError => (this as EitherDomainError<L, R>).domainError;

  /// The right side of [Either], which by convention is a success.
  R get executed => (this as EitherExecuted<L, R>).executed;

  /// Creates a failed [Either].
  const factory Either.domainError(L domainError) = EitherDomainError<L, R>;

  /// Creates a successful [Either].
  const factory Either.executed(R executed) = EitherExecuted<L, R>;

  /// Applies [ifFailed] or [ifExecuted] depending on the held value.
  T fold<T>(
    T Function(L domainError) ifFailed,
    T Function(R executed) ifExecuted,
  ) {
    if (isFailed) {
      return ifFailed(domainError);
    } else {
      return ifExecuted(executed);
    }
  }

  /// Calls [domainError] or [executed] with this [Either].
  void when({
    required void Function(Either<L, R> either) domainError,
    required void Function(Either<L, R> either) executed,
  }) {
    if (isFailed) {
      domainError(this);
    } else {
      executed(this);
    }
  }

  /// Maps this [Either] by calling [domainError] or [executed] with this instance.
  T map<T>({
    required T Function(Either<L, R> either) domainError,
    required T Function(Either<L, R> either) executed,
  }) {
    if (isFailed) {
      return domainError(this);
    } else {
      return executed(this);
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

/// [Either] that holds a domain error.
@immutable
class EitherDomainError<L, R> extends Either<L, R> {
  @override
  final L domainError;

  /// Creates a failed [Either].
  const EitherDomainError(this.domainError);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is EitherDomainError<L, R> && _eitherDeepEq.equals(other.domainError, domainError);
  }

  @override
  int get hashCode => _eitherDeepEq.hash(domainError);
}

/// [Either] that holds an executed value.
@immutable
class EitherExecuted<L, R> extends Either<L, R> {
  @override
  final R executed;

  /// Creates a successful [Either].
  const EitherExecuted(this.executed);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is EitherExecuted<L, R> && _eitherDeepEq.equals(other.executed, executed);
  }

  @override
  int get hashCode => _eitherDeepEq.hash(executed);
}
