import 'package:domain_error/domain_error.dart';
import 'package:test/test.dart';

void main() {
  group('executeSafely', () {
    test('returns thrown DomainError', () async {
      const error = _TestDomainError(message: 'handled error');

      final result = await executeSafely<void>(
        () => throw error,
        options: ExecuteSafelyOptions<void>(
          mapThrownToError: (error, stackTrace) => _TestDomainError(error: error),
        ),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure, error);
    });

    test('maps unexpected throw to DomainError', () async {
      final result = await executeSafely<void>(
        () => throw StateError('boom'),
        options: ExecuteSafelyOptions<void>(
          mapThrownToError: (error, stackTrace) => _TestDomainError(
            message: 'mapped error',
            error: error,
            stackTrace: stackTrace,
          ),
        ),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure.typeIdentifier, 'TestDomainError');
      expect(result.failure.message, 'mapped error');
    });
  });
}

final class _TestDomainError extends DomainError {
  const _TestDomainError({
    super.message,
    super.error,
    super.stackTrace,
  });

  @override
  String get typeIdentifier => 'TestDomainError';
}
