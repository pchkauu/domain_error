# domain_error

Turn thrown errors into values you can fold.

A domain error is a `DomainError`. An outcome is a `Result<T>`:
`Either<DomainError, T>`. `executeSafely` runs a function and returns that
result.

## Install

```yaml
dependencies:
  domain_error: ^1.0.0
```

## Use

One sealed error root per feature. Set `typeIdentifier` yourself. It stays
readable after obfuscation.

```dart
import 'dart:async';

import 'package:domain_error/domain_error.dart';

sealed class OrderError extends DomainError {
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

Catch throws. Map unexpected objects. Fold the result.

```dart
final result = await executeSafely<Order>(
  () {
    if (id.isEmpty) {
      throw const OrderIdEmptyError();
    }
    return loadOrder(id: id);
  },
  options: ExecuteSafelyOptions(
    mapThrownToError: (error, stackTrace) {
      if (error is TimeoutException) {
        return const OrderTimeoutError();
      } else {
        return OrderUnavailableError(error: error, stackTrace: stackTrace);
      }
    },
    onError: (error, stackTrace) { /* log */ },
    onThrown: (error, stackTrace) { /* log */ },
  ),
);

result.fold(
  (failure) => print(failure.typeIdentifier),
  (value) => print(value.title),
);
```

If the function throws a `DomainError`, you get that same object.
If it throws anything else, you get what `mapThrownToError` returns.
`onError` and `onThrown` only observe. They do not change the result.

Runnable sample: [`example/domain_error_example.dart`](example/domain_error_example.dart).

## License

MIT. Issues: https://github.com/pchkauu/domain_error/issues
