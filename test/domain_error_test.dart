import 'package:domain_error/domain_error.dart';
import 'package:test/test.dart';

void main() {
  group('DomainError', () {
    test('string representation uses type identifier and message', () {
      const error = _StableDomainError(message: 'signature mismatch');

      expect(error.toString(), 'StableDomainError(signature mismatch)');
    });

    test('string representation uses nested error type identifier', () {
      const error = _StableDomainError(
        cause: _NestedDomainError(message: 'nested'),
      );

      expect(error.toString(), 'StableDomainError(NestedDomainError)');
    });

    test('string representation does not depend on wrapped error runtimeType', () {
      final error = _StableDomainError(cause: _OpaqueError());

      expect(error.toString(), 'StableDomainError(opaque details)');
      expect(error.toString(), isNot(contains('_OpaqueError')));
    });

    test('diagnostic causes and stack traces do not affect equality', () {
      final first = _StableDomainError(message: 'same', cause: StateError('first'), stackTrace: StackTrace.current);
      final second = _StableDomainError(message: 'same', cause: StateError('second'), stackTrace: StackTrace.current);
      expect(first, equals(second));
      expect(first.hashCode, second.hashCode);
      expect({first, second}, hasLength(1));
      expect(first, isNot(equals(const _StableDomainError(message: 'different'))));
      expect(first, isNot(equals(const _NestedDomainError(message: 'same'))));
      expect(first, isNot(equals(const _IdentifierDomainError('other', message: 'same'))));
    });

    test('typeIdentifier participates in equality within the same concrete type', () {
      expect(const _IdentifierDomainError('a'), isNot(equals(const _IdentifierDomainError('b'))));
    });

    test('subclasses add business fields to equality', () {
      const first = _CodeDomainError(1, message: 'same');
      const second = _CodeDomainError(1, message: 'same', cause: 'diagnostic');
      expect(first, equals(second));
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(equals(const _CodeDomainError(2, message: 'same'))));
    });

    for (final separator in ['\n', '\r\n', '\r']) {
      test('normalizes messages and causes with separator ${separator.codeUnits}', () {
        final description = '  first  ${separator}second  ';
        expect(_StableDomainError(message: description).toString(), 'StableDomainError(first)');
        expect(_StableDomainError(cause: _Description(description)).toString(), 'StableDomainError(first)');
      });
    }

    test('message takes priority; whitespace falls back to the cause', () {
      expect(const _StableDomainError(message: ' message ', cause: 'cause').toString(), 'StableDomainError(message)');
      expect(const _StableDomainError(message: ' \n ', cause: 'cause').toString(), 'StableDomainError(cause)');
      expect(const _StableDomainError(message: ' \n ').toString(), 'StableDomainError');
    });

    test('empty, opaque, or throwing descriptions use unknown', () {
      for (final cause in [_Description('  '), Object(), _BrokenDescription()]) {
        expect(_StableDomainError(cause: cause).toString(), 'StableDomainError(unknown)');
      }
    });

    test('string representation omits empty details', () {
      const error = _StableDomainError();

      expect(error.toString(), 'StableDomainError');
    });
  });
}

final class _StableDomainError extends DomainError {
  @override
  String get typeIdentifier => 'StableDomainError';

  const _StableDomainError({
    super.message,
    super.cause,
    super.stackTrace,
  });
}

final class _NestedDomainError extends DomainError {
  @override
  String get typeIdentifier => 'NestedDomainError';

  const _NestedDomainError({
    super.message,
  });
}

final class _OpaqueError {
  @override
  String toString() => 'opaque details';
}

final class _IdentifierDomainError extends DomainError {
  @override
  final String typeIdentifier;

  const _IdentifierDomainError(this.typeIdentifier, {super.message});
}

final class _CodeDomainError extends DomainError {
  final int code;

  const _CodeDomainError(this.code, {super.message, super.cause});

  @override
  String get typeIdentifier => 'CodeDomainError';

  @override
  List<Object?> get props => [...super.props, code];
}

final class _Description {
  final String text;

  _Description(this.text);

  @override
  String toString() => text;
}

final class _BrokenDescription {
  @override
  String toString() => throw StateError('description failed');
}
