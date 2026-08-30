import 'dart:async';

import 'package:failure/src/entities/failure/failure.dart';
import 'package:failure/src/shared/_barrel.dart';

/// An [Either] whose failure side is [Failure].
typedef Result<T> = Either<Failure, T>;

/// A [Future] that completes with a [Result].
typedef FutureResult<T> = Future<Result<T>>;

/// A [FutureOr] that resolves to a [Result].
typedef FutureOrResult<T> = FutureOr<Result<T>>;
