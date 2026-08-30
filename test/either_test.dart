import 'package:domain_error/domain_error.dart';
import 'package:test/test.dart';

void main() {
  group('Either', () {
    test('successValue exposes payload and fold branch', () {
      const result = Either<DomainError, int>.ok(7);

      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.successValue, 7);
      expect(result.fold((errValue) => 0, (successValue) => successValue), 7);
    });

    test('errValue exposes payload and fold branch', () {
      const error = _TestDomainError(message: 'missing');
      const result = Either<DomainError, int>.err(error);

      expect(result.isErr, isTrue);
      expect(result.isOk, isFalse);
      expect(result.errValue, error);
      expect(result.fold((value) => value, (value) => value), error);
    });

    test('maps the success value and leaves an error unchanged', () {
      const ok = Either<DomainError, int>.ok(7);
      const err = Either<DomainError, int>.err(_TestDomainError(message: 'missing'));

      expect(ok.map((successValue) => successValue * 2).successValue, 14);
      expect(err.map((successValue) => successValue * 2).errValue, err.errValue);
    });

    test('compares equal when held values match', () {
      const left = Either<DomainError, String>.ok('ok');
      const right = Either<DomainError, String>.ok('ok');

      expect(left, equals(right));
    });

    test('can hold a left value that is not a DomainError', () {
      const result = Either<String, int>.err('missing');

      expect(result.isErr, isTrue);
      expect(result.errValue, 'missing');
    });
  });
}

final class _TestDomainError extends DomainError {
  @override
  String get typeIdentifier => 'TestDomainError';

  const _TestDomainError({
    super.message,
  });
}
