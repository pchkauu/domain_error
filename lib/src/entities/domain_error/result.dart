import 'dart:async';

import 'package:domain_error/src/entities/domain_error/domain_error.dart';
import 'package:domain_error/src/shared/_barrel.dart';

/// An [Either] whose failure side is [DomainError].
typedef Result<T> = Either<DomainError, T>;

/// A [Future] that completes with a [Result].
typedef FutureResult<T> = Future<Result<T>>;

/// A [FutureOr] that resolves to a [Result].
typedef FutureOrResult<T> = FutureOr<Result<T>>;
