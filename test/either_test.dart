import 'package:domain_error/domain_error.dart';
import 'package:test/test.dart';

void main() {
  group('Either', () {
    test('successValue exposes payload and fold branch', () {
      const result = Either<DomainError, int>.success(7);

      expect(result.isSuccess, isTrue);
      expect(result.isError, isFalse);
      expect(result.successValue, 7);
      expect(result.fold((errorValue) => 0, (successValue) => successValue), 7);
    });

    test('errorValue exposes payload and fold branch', () {
      const error = _TestDomainError(message: 'missing');
      const result = Either<DomainError, int>.error(error);

      expect(result.isError, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.errorValue, error);
      expect(result.fold((value) => value, (value) => value), error);
    });

    test('maps the success value and leaves an error unchanged', () {
      const ok = Either<DomainError, int>.success(7);
      const err = Either<DomainError, int>.error(_TestDomainError(message: 'missing'));

      expect(ok.map((successValue) => successValue * 2).successValue, 14);
      expect(err.map((successValue) => successValue * 2).errorValue, err.errorValue);
    });

    test('compares equal when held values match', () {
      const left = Either<DomainError, String>.success('ok');
      const right = Either<DomainError, String>.success('ok');

      expect(left, equals(right));
    });

    for (final errorBranch in [false, true]) {
      test('equality is symmetric with generic types, error branch: $errorBranch', () {
        final wide = errorBranch ? const Either<Object, num>.error('x') : const Either<Object, num>.success(1);
        final narrow = errorBranch ? const Either<String, int>.error('x') : const Either<String, int>.success(1);
        expect(wide == narrow, isFalse);
        expect(narrow == wide, isFalse);
        expect({wide, narrow}, hasLength(2));
      });

      test('deep equality and hashing, error branch: $errorBranch', () {
        final first = <String, Object?>{
          'list': [
            1,
            null,
            {
              'nested': [2, 3],
            },
          ],
          'set': {4, 5},
        };
        final second = <String, Object?>{
          'set': {5, 4},
          'list': [
            1,
            null,
            {
              'nested': [2, 3],
            },
          ],
        };
        final a = errorBranch ? Either<Object?, Object?>.error(first) : Either<Object?, Object?>.success(first);
        final b = errorBranch ? Either<Object?, Object?>.error(second) : Either<Object?, Object?>.success(second);
        expect(a == b, isTrue);
        expect(b == a, isTrue);
        expect(a.hashCode, b.hashCode);
        expect({a, b}, hasLength(1));
        expect({a}.contains(b), isTrue);
        final opposite = errorBranch ? Either<Object?, Object?>.success(first) : Either<Object?, Object?>.error(first);
        expect(a, isNot(equals(opposite)));
      });

      test('mixed collection kinds compare symmetrically, error branch: $errorBranch', () {
        final list = [1, 2];
        final iterable = list.map((value) => value);
        final a = errorBranch ? Either<Object, Object>.error(list) : Either<Object, Object>.success(list);
        final b = errorBranch ? Either<Object, Object>.error(iterable) : Either<Object, Object>.success(iterable);
        expect(a == b, isFalse);
        expect(b == a, isFalse);
      });
    }

    test('wrong branch getters throw StateError', () {
      const success = Either<String, int>.success(1);
      const error = Either<String, int>.error('missing');
      expect(() => success.errorValue, throwsStateError);
      expect(() => error.successValue, throwsStateError);
    });

    test('nullable values keep their branch identity', () {
      const success = Either<String?, int?>.success(null);
      const error = Either<String?, int?>.error(null);
      expect(success.isSuccess, isTrue);
      expect(success.successValue, isNull);
      expect(error.isError, isTrue);
      expect(error.errorValue, isNull);
      expect(success, isNot(equals(error)));
      expect(success.map((value) => value?.toString()).successValue, isNull);
    });

    test('error map never invokes the transform', () {
      const error = Either<String, int>.error('missing');
      final mapped = error.map<String>((value) => throw StateError('must not run'));
      expect(mapped.errorValue, error.errorValue);
    });

    test('unmodifiable snapshots preserve hashing after source collections change', () {
      final nested = [1, 2];
      final source = {'items': nested};
      final snapshot = Map<String, List<int>>.unmodifiable({
        for (final entry in source.entries) entry.key: List<int>.unmodifiable(entry.value),
      });
      final result = Either<String, Map<String, List<int>>>.success(snapshot);
      final hash = result.hashCode;
      final values = {result};
      nested.add(3);
      source.clear();
      expect(result.successValue, {
        'items': [1, 2],
      });
      expect(result.hashCode, hash);
      expect(values.contains(result), isTrue);
      expect(identical(result.successValue, snapshot), isTrue);
      expect(() => result.successValue.clear(), throwsUnsupportedError);
      expect(() => result.successValue['items']!.add(3), throwsUnsupportedError);
    });

    test('can hold a left value that is not a DomainError', () {
      const result = Either<String, int>.error('missing');

      expect(result.isError, isTrue);
      expect(result.errorValue, 'missing');
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
