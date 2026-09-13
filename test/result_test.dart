import 'package:domain_error/domain_error.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('domainError throws for a successful Result', () {
      const result = Either<DomainError, int>.success(7);
      expect(() => result.domainError, throwsStateError);
    });

    test('domainError reads the DomainError from a failed Result', () {
      const error = _TestDomainError(message: 'missing');
      const result = Either<DomainError, int>.error(error);

      expect(result.domainError, error);
      expect(result.domainError, result.errorValue);
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
