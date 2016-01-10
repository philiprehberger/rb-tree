# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.2] - 2026-03-24

### Fixed
- Remove inline comments from Development section to match template

## [0.1.1] - 2026-03-22

### Changed
- Update rubocop configuration for Windows compatibility

## [0.1.0] - 2026-03-22

### Added
- Initial release
- Generic tree node with value, children, and parent tracking
- Depth-first (pre-order) and breadth-first traversal
- Node search with predicate block
- Path finding from root to target value
- Leaf node collection
- Tree metrics: depth, height, and size
- Hash serialization via `to_h`
- Visual tree printing via `print_tree`
- Add and remove child operations
