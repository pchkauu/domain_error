# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.1] - 2026-08-30

### Added

- README diagrams for the error journey, the domain model, and the Result API.

## [2.1.0] - 2026-08-30

### Added

- `executeSafelySync` and `ExecuteSafelySyncOptions` for synchronous calls
  that return `Result<T>`.

## [2.0.0] - 2026-08-30

### Changed

- `ExecuteSafelyOptions`: `onError` is now `onDomainError`, `onThrown` is now
  `onRawError`, and `mapThrownToError` is now `mapRawErrorToDomain`.
  The options type is no longer generic and no longer extends `Equatable`.
- `DomainError.error` is now `rawError`.
- `Either` is sealed. The error branch is `isErr` / `errValue` / `Either.err`.
  The success branch is `isOk` / `successValue` / `Either.ok`.
- `fold` now takes `ifErr` and `ifOk`. `when` is removed. `map` maps the
  success value and leaves an error unchanged.
- `domainError` is available only on `Result<T>`, not on a generic `Either`.
- `executeSafely` now returns `Future<Result<T>>`. `FutureOrResult` is removed.

## [1.0.0] - 2026-08-30

### Added

- `DomainError` base type with a stable `typeIdentifier`, optional `message`,
  `error`, and `stackTrace`.
- `Either` with `failure` and `value` branches, plus `fold`, `when`, and `map`.
- `Result`, `FutureResult`, and `FutureOrResult` as `Either` aliases over
  `DomainError`.
- `executeSafely` to catch throws and return a `Result`.
- `ExecuteSafelyOptions` with `mapThrownToError`, `onError`, and `onThrown`.

[unreleased]: https://github.com/pchkauu/domain_error/compare/v2.1.1...HEAD
[2.1.1]: https://github.com/pchkauu/domain_error/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/pchkauu/domain_error/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/pchkauu/domain_error/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/pchkauu/domain_error/releases/tag/v1.0.0
