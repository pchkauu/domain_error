import 'package:domain_error/src/domain_error.dart';
import 'package:domain_error/src/either.dart';

/// An [Either] whose error side is [DomainError].
typedef Result<T> = Either<DomainError, T>;

/// A [Future] that completes with a [Result].
typedef FutureResult<T> = Future<Result<T>>;

/// Reads the [DomainError] from a failed [Result].
extension ResultDomainError<T> on Result<T> {
  /// The domain error held by this [Result].
  DomainError get domainError => errValue;
}
