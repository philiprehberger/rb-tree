# philiprehberger-tree

[![Tests](https://github.com/philiprehberger/rb-tree/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-tree/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-tree.svg)](https://rubygems.org/gems/philiprehberger-tree)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-tree)](https://github.com/philiprehberger/rb-tree/commits/main)

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
root.each_dfs { |node| puts node.value }        # depth-first pre-order
root.each_bfs { |node| puts node.value }        # breadth-first
root.each_post_order { |node| puts node.value } # depth-first post-order
```

### Search and Path Finding

```ruby
node = root.find { |n| n.value == 'grandchild' }
path = root.path_to('grandchild')
path.map(&:value)  # => ['root', 'child', 'grandchild']
```

### Value Lookup

```ruby
root.find_by_value('grandchild')   # => #<Node value="grandchild">
root.find_by_value('missing')      # => nil
root.include?('grandchild')        # => true
root.include?('missing')           # => false
```

### Select Matching Nodes

```ruby
matches = root.select { |n| n.value.to_s.start_with?('g') }
matches.map(&:value)  # => ['grandchild'] (DFS pre-order)
```

### Deserialization

```ruby
hash = { value: 'root', children: [{ value: 'child', children: [] }] }
tree = Philiprehberger::Tree::Node.from_h(hash)
tree.value  # => 'root'
```

### Map (Transform Values)

```ruby
mapped = root.map { |v| v.upcase }
mapped.value                     # => 'ROOT'
mapped.children.map(&:value)     # => ['CHILD']
```

### Flatten

```ruby
root.flatten  # => ['root', 'child', 'grandchild'] (DFS pre-order)
```

### Iterate with Depth

```ruby
root.each_with_depth do |node, depth|
  puts "#{'  ' * depth}#{node.value}"
end
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

### Subtree Extraction

```ruby
copy = child.subtree  # deep copy, detached from parent
copy.parent           # => nil
```

### Equality

```ruby
tree1 = Philiprehberger::Tree::Node.new('a')
tree2 = Philiprehberger::Tree::Node.new('a')
tree1 == tree2  # => true (structural equality)
```

### Ancestors and Siblings

```ruby
grandchild.ancestors.map(&:value)  # => ['child', 'root']
child.siblings.map(&:value)        # => ['other_child']
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
| `.from_h(hash)` | Reconstruct a tree from a hash (inverse of `#to_h`) |
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
| `#each_post_order` | Depth-first post-order iteration |
| `#find { \|n\| }` | Find first node matching predicate |
| `#find_by_value(value)` | Find first node whose value equals `value` |
| `#include?(value)` | True if any node has the given value |
| `#select { \|n\| }` | All nodes matching predicate (DFS pre-order) |
| `#path_to(value)` | Array of nodes from root to target |
| `#leaves` | All leaf nodes in subtree |
| `#subtree` | Deep copy of node and descendants |
| `#==` | Structural equality comparison |
| `#ancestors` | Array of ancestors from parent to root |
| `#siblings` | Sibling nodes excluding self |
| `#map { \|value\| }` | New tree with transformed values |
| `#flatten` | All values as flat array (DFS pre-order) |
| `#each_with_depth` | Iterate yielding node and depth level |
| `#to_h` | Serialize subtree to hash |
| `#print_tree` | Visual string representation |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-tree)

🐛 [Report issues](https://github.com/philiprehberger/rb-tree/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-tree/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
