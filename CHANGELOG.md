# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-08-30

### Changed

- `ExecuteSafelyOptions`: `onError` is now `onDomainError`, `onThrown` is now
  `onUnexpected`, and `mapThrownToError` is now `mapUnexpectedToDomainError`.
- `Either`: failed branch is `isFailed` / `domainError` / `Either.domainError`.
  Successful branch is `isExecuted` / `executed` / `Either.executed`.
- `fold` now takes `ifFailed` and `ifExecuted`. `when` and `map` use
  `domainError` and `executed`.

## [1.0.0] - 2026-08-30

### Added

- `DomainError` base type with a stable `typeIdentifier`, optional `message`,
  `error`, and `stackTrace`.
- `Either` with `failure` and `value` branches, plus `fold`, `when`, and `map`.
- `Result`, `FutureResult`, and `FutureOrResult` as `Either` aliases over
  `DomainError`.
- `executeSafely` to catch throws and return a `Result`.
- `ExecuteSafelyOptions` with `mapThrownToError`, `onError`, and `onThrown`.

[unreleased]: https://github.com/pchkauu/domain_error/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/pchkauu/domain_error/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/pchkauu/domain_error/releases/tag/v1.0.0
