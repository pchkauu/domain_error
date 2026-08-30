import 'package:domain_error/domain_error.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('domainError reads the DomainError from a failed Result', () {
      const error = _TestDomainError(message: 'missing');
      const result = Either<DomainError, int>.err(error);

      expect(result.domainError, error);
      expect(result.domainError, result.errValue);
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
