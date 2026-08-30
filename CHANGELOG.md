# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-08-30

### Added

- `Failure` base type with a stable `typeIdentifier`, optional `message`,
  `error`, and `stackTrace`.
- `Either` with `failure` and `value` branches, plus `fold`, `when`, and `map`.
- `Result`, `FutureResult`, and `FutureOrResult` as `Either` aliases over
  `Failure`.
- `executeSafely` to catch throws and return a `Result`.
- `ExecuteSafelyOptions` with `mapErrorToFailure`, `onFailure`, and `onError`.

[unreleased]: https://github.com/pchkauu/failure/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/pchkauu/failure/releases/tag/v1.0.0
