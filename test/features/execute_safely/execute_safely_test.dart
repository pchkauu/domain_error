import 'package:domain_error/domain_error.dart';
import 'package:test/test.dart';

void main() {
  group('executeSafely', () {
    test('returns thrown DomainError', () async {
      const error = _TestDomainError(message: 'handled error');

      final result = await executeSafely<void>(
        () => throw error,
        options: ExecuteSafelyOptions<void>(
          mapUnexpectedToDomainError: (error, stackTrace) => _TestDomainError(error: error),
        ),
      );

      expect(result.isFailed, isTrue);
      expect(result.domainError, error);
    });

    test('maps unexpected throw to DomainError', () async {
      final result = await executeSafely<void>(
        () => throw StateError('boom'),
        options: ExecuteSafelyOptions<void>(
          mapUnexpectedToDomainError: (error, stackTrace) => _TestDomainError(
            message: 'mapped error',
            error: error,
            stackTrace: stackTrace,
          ),
        ),
      );

      expect(result.isFailed, isTrue);
      expect(result.domainError.typeIdentifier, 'TestDomainError');
      expect(result.domainError.message, 'mapped error');
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
