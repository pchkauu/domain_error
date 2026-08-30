import 'package:domain_error/domain_error.dart';
import 'package:test/test.dart';

void main() {
  group('executeSafely', () {
    test('returns the successful value', () async {
      final result = await executeSafely<int>(
        () => 7,
        options: ExecuteSafelyOptions(
          mapRawErrorToDomain: (rawError, stackTrace) => _TestDomainError(rawError: rawError),
        ),
      );

      expect(result.isOk, isTrue);
      expect(result.successValue, 7);
    });

    test('returns thrown DomainError', () async {
      const error = _TestDomainError(message: 'handled error');
      DomainError? observedDomainError;

      final result = await executeSafely<void>(
        () => throw error,
        options: ExecuteSafelyOptions(
          mapRawErrorToDomain: (rawError, stackTrace) => _TestDomainError(rawError: rawError),
          onDomainError: (domainError, stackTrace) {
            observedDomainError = domainError;
          },
        ),
      );

      expect(result.isErr, isTrue);
      expect(result.domainError, error);
      expect(observedDomainError, error);
    });

    test('maps unexpected throw to DomainError', () async {
      Object? observedRawError;

      final result = await executeSafely<void>(
        () => throw StateError('boom'),
        options: ExecuteSafelyOptions(
          mapRawErrorToDomain: (rawError, stackTrace) => _TestDomainError(
            message: 'mapped error',
            rawError: rawError,
            stackTrace: stackTrace,
          ),
          onRawError: (rawError, stackTrace) {
            observedRawError = rawError;
          },
        ),
      );

      expect(result.isErr, isTrue);
      expect(result.domainError.typeIdentifier, 'TestDomainError');
      expect(result.domainError.message, 'mapped error');
      expect(observedRawError, isA<StateError>());
    });
  });
}

final class _TestDomainError extends DomainError {
  @override
  String get typeIdentifier => 'TestDomainError';

  const _TestDomainError({
    super.message,
    super.rawError,
    super.stackTrace,
  });
}
