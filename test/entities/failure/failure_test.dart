import 'package:failure/failure.dart';
import 'package:test/test.dart';

void main() {
  group('Failure', () {
    test('string representation uses type identifier and message', () {
      const failure = _StableFailure(message: 'signature mismatch');

      expect(failure.toString(), 'StableFailure(signature mismatch)');
    });

    test('string representation uses nested failure type identifier', () {
      const failure = _StableFailure(
        error: _NestedFailure(message: 'nested'),
      );

      expect(failure.toString(), 'StableFailure(NestedFailure)');
    });

    test('string representation does not depend on wrapped error runtimeType', () {
      final failure = _StableFailure(error: _OpaqueError());

      expect(failure.toString(), 'StableFailure(opaque details)');
      expect(failure.toString(), isNot(contains('_OpaqueError')));
    });

    test('string representation omits empty details', () {
      const failure = _StableFailure();

      expect(failure.toString(), 'StableFailure');
    });
  });
}

final class _StableFailure extends Failure {
  const _StableFailure({
    super.message,
    super.error,
  });

  @override
  String get typeIdentifier => 'StableFailure';
}

final class _NestedFailure extends Failure {
  const _NestedFailure({
    super.message,
  });

  @override
  String get typeIdentifier => 'NestedFailure';
}

final class _OpaqueError {
  @override
  String toString() => 'opaque details';
}
