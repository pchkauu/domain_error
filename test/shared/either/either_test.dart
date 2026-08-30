import 'package:domain_error/domain_error.dart';
import 'package:test/test.dart';

void main() {
  group('Either', () {
    test('executed exposes payload and fold branch', () {
      const result = Either<DomainError, int>.executed(7);

      expect(result.isExecuted, isTrue);
      expect(result.isFailed, isFalse);
      expect(result.executed, 7);
      expect(result.fold((domainError) => 0, (executed) => executed), 7);
    });

    test('domainError exposes payload and fold branch', () {
      const error = _TestDomainError(message: 'missing');
      const result = Either<DomainError, int>.domainError(error);

      expect(result.isFailed, isTrue);
      expect(result.isExecuted, isFalse);
      expect(result.domainError, error);
      expect(result.fold((value) => value, (value) => value), error);
    });

    test('compares equal when held values match', () {
      const left = Either<DomainError, String>.executed('ok');
      const right = Either<DomainError, String>.executed('ok');

      expect(left, equals(right));
    });

    test('can hold a left value that is not a DomainError', () {
      const result = Either<String, int>.domainError('missing');

      expect(result.isFailed, isTrue);
      expect(result.domainError, 'missing');
    });
  });
}

final class _TestDomainError extends DomainError {
  const _TestDomainError({
    super.message,
  });

  @override
  String get typeIdentifier => 'TestDomainError';
}
