import 'package:failure/failure.dart';
import 'package:test/test.dart';

void main() {
  group('Either', () {
    test('value exposes payload and fold branch', () {
      const result = Either<Failure, int>.value(7);

      expect(result.isValue, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, 7);
      expect(result.fold((failure) => 0, (value) => value), 7);
    });

    test('failure exposes payload and fold branch', () {
      const failure = _TestFailure(message: 'missing');
      const result = Either<Failure, int>.failure(failure);

      expect(result.isFailure, isTrue);
      expect(result.isValue, isFalse);
      expect(result.failure, failure);
      expect(result.fold((value) => value, (value) => value), failure);
    });

    test('compares equal when held values match', () {
      const left = Either<Failure, String>.value('ok');
      const right = Either<Failure, String>.value('ok');

      expect(left, equals(right));
    });

    test('can hold a left value that is not a Failure', () {
      const result = Either<String, int>.failure('missing');

      expect(result.isFailure, isTrue);
      expect(result.failure, 'missing');
    });
  });
}

final class _TestFailure extends Failure {
  const _TestFailure({
    super.message,
  });

  @override
  String get typeIdentifier => 'TestFailure';
}
