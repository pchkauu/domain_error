import 'package:failure/failure.dart';
import 'package:test/test.dart';

void main() {
  group('executeSafely', () {
    test('returns thrown Failure', () async {
      const failure = _TestFailure(message: 'handled failure');

      final result = await executeSafely<void>(
        () => throw failure,
        options: ExecuteSafelyOptions<void>(
          mapErrorToFailure: (error, stackTrace) => _TestFailure(error: error),
        ),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure, failure);
    });

    test('maps unexpected error to Failure', () async {
      final result = await executeSafely<void>(
        () => throw StateError('boom'),
        options: ExecuteSafelyOptions<void>(
          mapErrorToFailure: (error, stackTrace) => _TestFailure(
            message: 'mapped failure',
            error: error,
            stackTrace: stackTrace,
          ),
        ),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure.typeIdentifier, 'TestFailure');
      expect(result.failure.message, 'mapped failure');
    });
  });
}

final class _TestFailure extends Failure {
  const _TestFailure({
    super.message,
    super.error,
    super.stackTrace,
  });

  @override
  String get typeIdentifier => 'TestFailure';
}
