# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## 1.6.0

### Fixed
- Fix array splat errors under Ruby 3 (PR thanks to @evgeni)

## 1.5.0

### Added
- Add `AS_DEPRECATION_DISABLE` environment variable to fully disable ASDT.
- Support shorter `ASDT_` prefix for all environment variables.

## 1.4.1

### Fixed
- Fix YAML safe load error under Ruby 2.0.

## 1.4.0

### Added
- Add pause!/resume! API to temporarily queue deprecation processing.

### Fixed
- Fix engine root search error when engine name is given as a symbol.

## 1.3.0

### Changed
- Deprecation messages are matched by prefix, so only the first part of the
  message needs to be stored on the whitelist entry.

### Fixed
- Fix error loading empty whitelist file.

## 1.2.0

### Changed
- Multi-line deprecation messages are matched line-by-line, so only the first
  lines need to be stored in the whitelist entry.
- Use safe YAML load on configuration files.

### Fixed
- Fix duplicate entries created during record mode.
- Fix Rails 5 callstack compatibility when matching deprecations.
- Fix array comparison error when matching entries without callstacks.

## 1.1.0

### Added
- Add `AS_DEPRECATION_WHITELIST` environment variable to load/write whitelist
  to a different path.
- Load and merge whitelist config files from each Rails engine root.
- Add `engine` config option to whitelist, matches engine name.
- Add whitelist API to add new entries programmatically.

### Changed
- Raise errors for unknown config options in whitelist.

### Fixed
- Fix callstack matching against whitelist with relative paths.

## 1.0.0

### Added
- Initial release, supporting raising of exceptions and recording mode.
