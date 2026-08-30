# failure

Turn thrown errors into values you can fold.

A domain error is a `Failure`. An outcome is a `Result<T>`: `Either<Failure, T>`.
`executeSafely` runs a function and returns that result.

## Install

```yaml
dependencies:
  failure: ^1.0.0
```

## Use

One sealed error root per feature. Set `typeIdentifier` yourself. It stays
readable after obfuscation.

```dart
import 'dart:async';

import 'package:failure/failure.dart';

sealed class OrderError extends Failure {
  const OrderError({super.message, super.error, super.stackTrace});

  @override
  String get typeIdentifier => 'OrderError';
}

final class OrderIdEmptyError extends OrderError {
  const OrderIdEmptyError();

  @override
  String get typeIdentifier => 'OrderIdEmptyError';
}

final class OrderTimeoutError extends OrderError {
  const OrderTimeoutError();

  @override
  String get typeIdentifier => 'OrderTimeoutError';
}

final class OrderUnavailableError extends OrderError {
  const OrderUnavailableError({super.error, super.stackTrace});

  @override
  String get typeIdentifier => 'OrderUnavailableError';
}
```

Catch throws. Map unexpected errors. Fold the result.

```dart
final result = await executeSafely<Order>(
  () {
    if (id.isEmpty) {
      throw const OrderIdEmptyError();
    }
    return loadOrder(id: id);
  },
  options: ExecuteSafelyOptions(
    mapErrorToFailure: (error, stackTrace) {
      if (error is TimeoutException) {
        return const OrderTimeoutError();
      } else {
        return OrderUnavailableError(error: error, stackTrace: stackTrace);
      }
    },
    onFailure: (failure, stackTrace) { /* log */ },
    onError: (error, stackTrace) { /* log */ },
  ),
);

result.fold(
  (failure) => print(failure.typeIdentifier),
  (value) => print(value.title),
);
```

If the function throws a `Failure`, you get that same object.
If it throws anything else, you get what `mapErrorToFailure` returns.
`onFailure` and `onError` only observe. They do not change the result.

Runnable sample: [`example/failure_example.dart`](example/failure_example.dart).

## License

MIT. Issues: https://github.com/pchkauu/failure/issues
