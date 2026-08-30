# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-08-30

### Added

- `DomainError` base type with a stable `typeIdentifier`, optional `message`,
  `error`, and `stackTrace`.
- `Either` with `failure` and `value` branches, plus `fold`, `when`, and `map`.
- `Result`, `FutureResult`, and `FutureOrResult` as `Either` aliases over
  `DomainError`.
- `executeSafely` to catch throws and return a `Result`.
- `ExecuteSafelyOptions` with `mapThrownToError`, `onError`, and `onThrown`.

[unreleased]: https://github.com/pchkauu/domain_error/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/pchkauu/domain_error/releases/tag/v1.0.0
