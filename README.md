# philiprehberger-tree

[![Tests](https://github.com/philiprehberger/rb-tree/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-tree/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-tree.svg)](https://rubygems.org/gems/philiprehberger-tree)
[![License](https://img.shields.io/github/license/philiprehberger/rb-tree)](LICENSE)

Generic tree data structure with traversal, search, and serialization

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-tree"
```

Or install directly:

```bash
gem install philiprehberger-tree
```

## Usage

```ruby
require "philiprehberger/tree"

root = Philiprehberger::Tree::Node.new('root')
child = root.add_child('child')
child.add_child('grandchild')

root.size      # => 3
root.height    # => 2
root.leaf?     # => false
child.depth    # => 1
```

### Traversal

```ruby
root.each_dfs { |node| puts node.value }   # depth-first pre-order
root.each_bfs { |node| puts node.value }   # breadth-first
```

### Search and Path Finding

```ruby
node = root.find { |n| n.value == 'grandchild' }
path = root.path_to('grandchild')
path.map(&:value)  # => ['root', 'child', 'grandchild']
```

### Serialization

```ruby
root.to_h
# => { value: 'root', children: [{ value: 'child', children: [...] }] }

puts root.print_tree
# root
# └── child
#     └── grandchild
```

### Leaf Collection

```ruby
root.leaves.map(&:value)  # => ['grandchild']
```

## API

### `Node`

| Method | Description |
|--------|-------------|
| `.new(value)` | Create a new tree node |
| `#add_child(value)` | Add a child node and return it |
| `#remove_child(value)` | Remove a child by value |
| `#children` | Array of child nodes |
| `#parent` | Parent node or nil |
| `#root?` | True if node has no parent |
| `#leaf?` | True if node has no children |
| `#depth` | Distance from root |
| `#height` | Height of subtree |
| `#size` | Total nodes in subtree |
| `#each_dfs` | Depth-first pre-order iteration |
| `#each_bfs` | Breadth-first iteration |
| `#find { \|n\| }` | Find first node matching predicate |
| `#path_to(value)` | Array of nodes from root to target |
| `#leaves` | All leaf nodes in subtree |
| `#to_h` | Serialize subtree to hash |
| `#print_tree` | Visual string representation |

## Development

```bash
bundle install
bundle exec rspec      # Run tests
bundle exec rubocop    # Check code style
```

## License

MIT
