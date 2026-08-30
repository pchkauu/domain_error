import 'package:domain_error/domain_error.dart';
import 'package:test/test.dart';

void main() {
  group('Either', () {
    test('value exposes payload and fold branch', () {
      const result = Either<DomainError, int>.value(7);

      expect(result.isValue, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, 7);
      expect(result.fold((failure) => 0, (value) => value), 7);
    });

    test('failure exposes payload and fold branch', () {
      const error = _TestDomainError(message: 'missing');
      const result = Either<DomainError, int>.failure(error);

      expect(result.isFailure, isTrue);
      expect(result.isValue, isFalse);
      expect(result.failure, error);
      expect(result.fold((value) => value, (value) => value), error);
    });

    test('compares equal when held values match', () {
      const left = Either<DomainError, String>.value('ok');
      const right = Either<DomainError, String>.value('ok');

      expect(left, equals(right));
    });

    test('can hold a left value that is not a DomainError', () {
      const result = Either<String, int>.failure('missing');

      expect(result.isFailure, isTrue);
      expect(result.failure, 'missing');
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
