# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2026-04-17

### Added
- `Node#paths` returns all root-to-leaf paths in the subtree as arrays of nodes (DFS pre-order); a leaf receiver returns `[[self]]`

## [0.5.0] - 2026-04-16

### Added
- `Node#prune(max_depth:)` removes all descendants deeper than `max_depth` levels below the receiver (mutates in place, returns `self`)
- `max_depth: 0` removes all children; higher values keep that many levels and remove deeper descendants
- Raises `ArgumentError` when `max_depth` is not a non-negative Integer

## [0.4.0] - 2026-04-15

### Added
- `Node#find_by_value(value)` returns the first node whose value equals the given value (DFS pre-order)
- `Node#include?(value)` returns true when any node in the subtree has the given value
- `Node#select { |node| }` returns all nodes in the subtree matching the predicate block

## [0.3.0] - 2026-04-09

### Added
- `Node.from_h(hash)` to reconstruct a tree from a hash (inverse of `to_h`)
- `Node#map` to create a new tree with transformed values
- `Node#flatten` to collect all values as a flat array
- `Node#each_with_depth` to iterate yielding node and depth level

## [0.2.0] - 2026-04-03

### Added
- Post-order depth-first traversal via `each_post_order`
- Deep subtree extraction via `subtree`
- Structural equality via `==`
- `ancestors` method returning path from parent to root
- `siblings` method returning sibling nodes

## [0.1.5] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.4] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.3] - 2026-03-26

### Fixed
- Add Sponsor badge to README
- Fix license section link format

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

[0.6.0]: https://github.com/philiprehberger/rb-tree/releases/tag/v0.6.0
[0.5.0]: https://github.com/philiprehberger/rb-tree/releases/tag/v0.5.0
[0.4.0]: https://github.com/philiprehberger/rb-tree/releases/tag/v0.4.0
[0.3.0]: https://github.com/philiprehberger/rb-tree/releases/tag/v0.3.0
[0.2.0]: https://github.com/philiprehberger/rb-tree/releases/tag/v0.2.0
[0.1.5]: https://github.com/philiprehberger/rb-tree/releases/tag/v0.1.5
[0.1.4]: https://github.com/philiprehberger/rb-tree/releases/tag/v0.1.4
[0.1.3]: https://github.com/philiprehberger/rb-tree/releases/tag/v0.1.3
[0.1.2]: https://github.com/philiprehberger/rb-tree/releases/tag/v0.1.2
[0.1.1]: https://github.com/philiprehberger/rb-tree/releases/tag/v0.1.1
[0.1.0]: https://github.com/philiprehberger/rb-tree/releases/tag/v0.1.0
