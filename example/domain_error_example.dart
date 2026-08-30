// ignore_for_file: unreachable_from_main, avoid_print

import 'dart:async';

import 'package:domain_error/domain_error.dart';

/// Loads an order and prints `successValue` / `errValue` for typical outcomes.
void main() async {
  const op = 'main():';

  for (final id in ['42', '', 'timeout', 'boom']) {
    final result = await executeSafely<Order>(
      () async {
        if (id.isEmpty) {
          throw const OrderIdEmptyError();
        }
        return loadOrder(id: id);
      },
      options: ExecuteSafelyOptions(
        mapRawErrorToDomain: (rawError, stackTrace) {
          if (rawError is TimeoutException) {
            return const OrderTimeoutError();
          } else {
            return OrderUnavailableError(rawError: rawError, stackTrace: stackTrace);
          }
        },
        onDomainError: (domainError, stackTrace) async {
          print('$op ${domainError.typeIdentifier} ${domainError.stackTrace}');
        },
        onRawError: (rawError, stackTrace) async {
          print('$op $rawError $stackTrace');
        },
      ),
    );

    print(
      result.fold(
        (domainError) => '$op $domainError',
        (successValue) => '$op $successValue',
      ),
    );
  }

  final syncResult = executeSafelySync<Order>(
    () => loadOrder(id: '42'),
    options: ExecuteSafelySyncOptions(
      mapRawErrorToDomain: (rawError, stackTrace) {
        return OrderUnavailableError(rawError: rawError, stackTrace: stackTrace);
      },
    ),
  );
  print(
    syncResult.fold(
      (domainError) => '$op sync $domainError',
      (successValue) => '$op sync $successValue',
    ),
  );
}

/// Reads an order or throws a domain [DomainError] / unexpected error.
Order loadOrder({required String id}) {
  if (id.trim().isEmpty) {
    throw const OrderIdEmptyError();
  }
  if (id == 'timeout') {
    throw TimeoutException('warehouse timeout');
  }
  if (id == 'boom') {
    throw StateError('warehouse timeout');
  }
  return Order(id: id, title: 'Notebook');
}

final class Order {
  final String id;
  final String title;

  const Order({
    required this.id,
    required this.title,
  });
}

sealed class OrderError extends DomainError {
  @override
  String get typeIdentifier => 'OrderError';

  const OrderError({
    super.message,
    super.rawError,
    super.stackTrace,
  });
}

final class OrderIdEmptyError extends OrderError {
  @override
  String get typeIdentifier => 'OrderIdEmptyError';

  const OrderIdEmptyError();
}

final class OrderTimeoutError extends OrderError {
  @override
  String get typeIdentifier => 'OrderTimeoutError';

  const OrderTimeoutError();
}

final class OrderUnavailableError extends OrderError {
  @override
  String get typeIdentifier => 'OrderUnavailableError';

  const OrderUnavailableError({
    super.rawError,
    super.stackTrace,
  });
}
