import 'package:domain_error/domain_error.dart';
import 'package:test/test.dart';

void main() {
  group('DomainError', () {
    test('string representation uses type identifier and message', () {
      const error = _StableDomainError(message: 'signature mismatch');

      expect(error.toString(), 'StableDomainError(signature mismatch)');
    });

    test('string representation uses nested error type identifier', () {
      const error = _StableDomainError(
        error: _NestedDomainError(message: 'nested'),
      );

      expect(error.toString(), 'StableDomainError(NestedDomainError)');
    });

    test('string representation does not depend on wrapped error runtimeType', () {
      final error = _StableDomainError(error: _OpaqueError());

      expect(error.toString(), 'StableDomainError(opaque details)');
      expect(error.toString(), isNot(contains('_OpaqueError')));
    });

    test('string representation omits empty details', () {
      const error = _StableDomainError();

      expect(error.toString(), 'StableDomainError');
    });
  });
}

final class _StableDomainError extends DomainError {
  const _StableDomainError({
    super.message,
    super.error,
  });

  @override
  String get typeIdentifier => 'StableDomainError';
}

final class _NestedDomainError extends DomainError {
  const _NestedDomainError({
    super.message,
  });

  @override
  String get typeIdentifier => 'NestedDomainError';
}

final class _OpaqueError {
  @override
  String toString() => 'opaque details';
}
