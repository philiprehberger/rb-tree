# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Tree do
  describe 'VERSION' do
    it 'has a version number' do
      expect(Philiprehberger::Tree::VERSION).not_to be_nil
    end
  end
end

RSpec.describe Philiprehberger::Tree::Node do
  let(:root) { described_class.new('root') }

  describe '.new' do
    it 'creates a node with the given value' do
      node = described_class.new(42)
      expect(node.value).to eq(42)
    end

    it 'starts with no children' do
      expect(root.children).to be_empty
    end

    it 'starts with no parent' do
      expect(root.parent).to be_nil
    end
  end

  describe '#add_child' do
    it 'adds a child node with the given value' do
      child = root.add_child('child')
      expect(child.value).to eq('child')
      expect(root.children).to eq([child])
    end

    it 'sets the parent of the child' do
      child = root.add_child('child')
      expect(child.parent).to eq(root)
    end

    it 'adds multiple children' do
      root.add_child('a')
      root.add_child('b')
      expect(root.children.map(&:value)).to eq(%w[a b])
    end
  end

  describe '#remove_child' do
    it 'removes a child by value' do
      root.add_child('a')
      root.add_child('b')
      removed = root.remove_child('a')
      expect(removed.value).to eq('a')
      expect(root.children.map(&:value)).to eq(['b'])
    end

    it 'clears the parent of the removed child' do
      child = root.add_child('a')
      root.remove_child('a')
      expect(child.parent).to be_nil
    end

    it 'returns nil if child not found' do
      expect(root.remove_child('missing')).to be_nil
    end
  end

  describe '#root?' do
    it 'returns true for root node' do
      expect(root).to be_root
    end

    it 'returns false for child node' do
      child = root.add_child('child')
      expect(child).not_to be_root
    end
  end

  describe '#leaf?' do
    it 'returns true for node with no children' do
      expect(root).to be_leaf
    end

    it 'returns false for node with children' do
      root.add_child('child')
      expect(root).not_to be_leaf
    end
  end

  describe '#depth' do
    it 'returns 0 for root' do
      expect(root.depth).to eq(0)
    end

    it 'returns correct depth for nested nodes' do
      child = root.add_child('child')
      grandchild = child.add_child('grandchild')
      expect(child.depth).to eq(1)
      expect(grandchild.depth).to eq(2)
    end
  end

  describe '#height' do
    it 'returns 0 for leaf node' do
      expect(root.height).to eq(0)
    end

    it 'returns correct height for tree' do
      child = root.add_child('child')
      child.add_child('grandchild')
      expect(root.height).to eq(2)
    end
  end

  describe '#size' do
    it 'returns 1 for single node' do
      expect(root.size).to eq(1)
    end

    it 'counts all nodes in the subtree' do
      child = root.add_child('a')
      child.add_child('b')
      root.add_child('c')
      expect(root.size).to eq(4)
    end
  end

  describe '#each_dfs' do
    it 'iterates in depth-first pre-order' do
      a = root.add_child('a')
      a.add_child('a1')
      a.add_child('a2')
      root.add_child('b')

      values = root.each_dfs.map(&:value)
      expect(values).to eq(%w[root a a1 a2 b])
    end

    it 'returns an enumerator when no block given' do
      expect(root.each_dfs).to be_an(Enumerator)
    end
  end

  describe '#each_bfs' do
    it 'iterates in breadth-first order' do
      a = root.add_child('a')
      a.add_child('a1')
      a.add_child('a2')
      root.add_child('b')

      values = root.each_bfs.map(&:value)
      expect(values).to eq(%w[root a b a1 a2])
    end

    it 'returns an enumerator when no block given' do
      expect(root.each_bfs).to be_an(Enumerator)
    end
  end

  describe '#each_post_order' do
    it 'iterates in depth-first post-order (children before parent)' do
      a = root.add_child('a')
      a.add_child('a1')
      a.add_child('a2')
      root.add_child('b')

      values = root.each_post_order.map(&:value)
      expect(values).to eq(%w[a1 a2 a b root])
    end

    it 'returns an enumerator when no block given' do
      expect(root.each_post_order).to be_an(Enumerator)
    end

    it 'yields single node for root-only tree' do
      values = root.each_post_order.map(&:value)
      expect(values).to eq(['root'])
    end
  end

  describe '#subtree' do
    it 'returns a deep copy detached from parent' do
      child = root.add_child('child')
      child.add_child('grandchild')

      copy = child.subtree
      expect(copy.value).to eq('child')
      expect(copy.parent).to be_nil
      expect(copy.children.map(&:value)).to eq(['grandchild'])
    end

    it 'does not affect original when copy is modified' do
      child = root.add_child('child')
      grandchild = child.add_child('grandchild')

      copy = child.subtree
      copy.add_child('new_node')

      expect(child.children.map(&:value)).to eq(['grandchild'])
      expect(grandchild.children).to be_empty
    end

    it 'works for a single node' do
      copy = root.subtree
      expect(copy.value).to eq('root')
      expect(copy.children).to be_empty
      expect(copy.parent).to be_nil
    end
  end

  describe '#==' do
    it 'returns true for structurally identical trees' do
      tree1 = described_class.new('root')
      tree1.add_child('a')
      tree1.add_child('b')

      tree2 = described_class.new('root')
      tree2.add_child('a')
      tree2.add_child('b')

      expect(tree1).to eq(tree2)
    end

    it 'returns false for different values' do
      tree1 = described_class.new('root')
      tree2 = described_class.new('other')

      expect(tree1).not_to eq(tree2)
    end

    it 'returns false for different shapes' do
      tree1 = described_class.new('root')
      tree1.add_child('a')

      tree2 = described_class.new('root')
      tree2.add_child('a')
      tree2.add_child('b')

      expect(tree1).not_to eq(tree2)
    end

    it 'returns false for non-Node objects' do
      expect(root).not_to eq('root')
    end

    it 'checks children recursively' do
      tree1 = described_class.new('root')
      a1 = tree1.add_child('a')
      a1.add_child('deep')

      tree2 = described_class.new('root')
      a2 = tree2.add_child('a')
      a2.add_child('different')

      expect(tree1).not_to eq(tree2)
    end
  end

  describe '#ancestors' do
    it 'returns ancestors from parent to root' do
      child = root.add_child('child')
      grandchild = child.add_child('grandchild')

      ancestor_values = grandchild.ancestors.map(&:value)
      expect(ancestor_values).to eq(%w[child root])
    end

    it 'returns empty array for root node' do
      expect(root.ancestors).to be_empty
    end

    it 'returns only parent for direct child' do
      child = root.add_child('child')
      expect(child.ancestors.map(&:value)).to eq(['root'])
    end
  end

  describe '#siblings' do
    it 'returns sibling nodes excluding self' do
      a = root.add_child('a')
      root.add_child('b')
      root.add_child('c')

      sibling_values = a.siblings.map(&:value)
      expect(sibling_values).to eq(%w[b c])
    end

    it 'returns empty array for root node' do
      expect(root.siblings).to be_empty
    end

    it 'returns empty array for only child' do
      child = root.add_child('only')
      expect(child.siblings).to be_empty
    end
  end

  describe '.from_h' do
    it 'reconstructs a tree from a hash' do
      hash = { value: 'root', children: [
        { value: 'a', children: [{ value: 'a1', children: [] }] },
        { value: 'b', children: [] }
      ] }

      tree = described_class.from_h(hash)
      expect(tree.value).to eq('root')
      expect(tree.children.map(&:value)).to eq(%w[a b])
      expect(tree.children[0].children[0].value).to eq('a1')
    end

    it 'sets parent references correctly' do
      hash = { value: 'root', children: [{ value: 'child', children: [] }] }
      tree = described_class.from_h(hash)
      expect(tree.children[0].parent).to eq(tree)
    end

    it 'round-trips through to_h' do
      child = root.add_child('a')
      child.add_child('a1')
      root.add_child('b')

      rebuilt = described_class.from_h(root.to_h)
      expect(rebuilt).to eq(root)
    end

    it 'handles a single node' do
      tree = described_class.from_h({ value: 'solo', children: [] })
      expect(tree.value).to eq('solo')
      expect(tree.children).to be_empty
      expect(tree.parent).to be_nil
    end
  end

  describe '#map' do
    it 'transforms values while preserving structure' do
      root.add_child('a')
      root.add_child('b')

      mapped = root.map(&:upcase)
      expect(mapped.value).to eq('ROOT')
      expect(mapped.children.map(&:value)).to eq(%w[A B])
    end

    it 'sets parent references on the new tree' do
      child = root.add_child('a')
      child.add_child('a1')

      mapped = root.map(&:upcase)
      expect(mapped.children[0].parent).to eq(mapped)
      expect(mapped.children[0].children[0].parent.value).to eq('A')
    end

    it 'does not modify the original tree' do
      root.add_child('a')
      root.map(&:upcase)
      expect(root.value).to eq('root')
    end

    it 'works on a single node' do
      mapped = root.map(&:length)
      expect(mapped.value).to eq(4)
      expect(mapped.children).to be_empty
    end
  end

  describe '#flatten' do
    it 'returns all values in DFS pre-order' do
      a = root.add_child('a')
      a.add_child('a1')
      root.add_child('b')

      expect(root.flatten).to eq(%w[root a a1 b])
    end

    it 'returns single-element array for leaf node' do
      expect(root.flatten).to eq(['root'])
    end
  end

  describe '#each_with_depth' do
    it 'yields node and depth pairs' do
      a = root.add_child('a')
      a.add_child('a1')
      root.add_child('b')

      pairs = root.each_with_depth.map { |node, depth| [node.value, depth] }
      expect(pairs).to eq([['root', 0], ['a', 1], ['a1', 2], ['b', 1]])
    end

    it 'returns an enumerator when no block given' do
      expect(root.each_with_depth).to be_an(Enumerator)
    end

    it 'yields depth 0 for a single root' do
      pairs = root.each_with_depth.map { |_node, depth| depth }
      expect(pairs).to eq([0])
    end
  end

  describe '#find' do
    it 'finds a node by predicate' do
      root.add_child('target')
      node = root.find { |n| n.value == 'target' }
      expect(node.value).to eq('target')
    end

    it 'finds nested nodes' do
      child = root.add_child('a')
      child.add_child('deep')
      node = root.find { |n| n.value == 'deep' }
      expect(node.value).to eq('deep')
    end

    it 'returns nil when not found' do
      expect(root.find { |n| n.value == 'missing' }).to be_nil
    end
  end

  describe '#find_by_value' do
    it 'returns the first node with the given value' do
      root.add_child('target')
      node = root.find_by_value('target')
      expect(node.value).to eq('target')
    end

    it 'finds nested values' do
      child = root.add_child('a')
      child.add_child('deep')
      expect(root.find_by_value('deep').value).to eq('deep')
    end

    it 'returns nil when value is not present' do
      expect(root.find_by_value('missing')).to be_nil
    end

    it 'returns self when value matches root' do
      expect(root.find_by_value('root')).to eq(root)
    end

    it 'returns the first match in DFS pre-order when duplicates exist' do
      a = root.add_child('a')
      a.add_child('dup')
      b = root.add_child('b')
      b_dup = b.add_child('dup')

      found = root.find_by_value('dup')
      expect(found).not_to equal(b_dup)
      expect(found.parent.value).to eq('a')
    end
  end

  describe '#include?' do
    it 'returns true when a node with the value exists' do
      root.add_child('a')
      expect(root.include?('a')).to be(true)
    end

    it 'returns true for deeply nested values' do
      child = root.add_child('a')
      child.add_child('deep')
      expect(root.include?('deep')).to be(true)
    end

    it 'returns false when no node has the value' do
      expect(root.include?('missing')).to be(false)
    end

    it 'returns true for the root value' do
      expect(root.include?('root')).to be(true)
    end

    it 'returns false for nil when no nil values exist' do
      root.add_child('a')
      expect(root.include?(nil)).to be(false)
    end
  end

  describe '#select' do
    it 'returns all nodes matching the predicate' do
      root.add_child('a')
      root.add_child('b')
      root.add_child('a')

      matches = root.select { |n| n.value == 'a' }
      expect(matches.map(&:value)).to eq(%w[a a])
    end

    it 'returns matching nodes in DFS pre-order' do
      a = root.add_child('a')
      a.add_child('x')
      b = root.add_child('b')
      b.add_child('x')

      xs = root.select { |n| n.value == 'x' }
      expect(xs.map { |n| n.parent.value }).to eq(%w[a b])
    end

    it 'returns an empty array when nothing matches' do
      root.add_child('a')
      expect(root.select { |n| n.value == 'missing' }).to eq([])
    end

    it 'returns an empty array when no block is given' do
      root.add_child('a')
      expect(root.select).to eq([])
    end

    it 'can match by arbitrary predicate, including self' do
      root.add_child('short')
      root.add_child('longer_value')
      matches = root.select { |n| n.value.to_s.length > 4 }
      expect(matches.map(&:value)).to contain_exactly('short', 'longer_value')
    end
  end

  describe '#path_to' do
    it 'returns the path from root to a node' do
      child = root.add_child('a')
      grandchild = child.add_child('b')
      grandchild.add_child('c')

      path = root.path_to('c')
      expect(path.map(&:value)).to eq(%w[root a b c])
    end

    it 'returns nil when value not found' do
      expect(root.path_to('missing')).to be_nil
    end

    it 'returns single-element path for root value' do
      path = root.path_to('root')
      expect(path.map(&:value)).to eq(['root'])
    end
  end

  describe '#leaves' do
    it 'returns leaf nodes' do
      a = root.add_child('a')
      a.add_child('a1')
      a.add_child('a2')
      root.add_child('b')

      leaf_values = root.leaves.map(&:value)
      expect(leaf_values).to contain_exactly('a1', 'a2', 'b')
    end

    it 'returns root when tree is a single node' do
      expect(root.leaves).to eq([root])
    end
  end

  describe '#to_h' do
    it 'serializes the tree to a hash' do
      child = root.add_child('a')
      child.add_child('a1')

      expected = {
        value: 'root',
        children: [
          {
            value: 'a',
            children: [
              { value: 'a1', children: [] }
            ]
          }
        ]
      }
      expect(root.to_h).to eq(expected)
    end
  end

  describe '#print_tree' do
    it 'returns a string representation' do
      root.add_child('a')
      root.add_child('b')

      output = root.print_tree
      expect(output).to include('root')
      expect(output).to include('a')
      expect(output).to include('b')
    end
  end

  describe '#prune' do
    let(:deep_tree) do
      tree = described_class.new('root')
      a = tree.add_child('a')
      a1 = a.add_child('a1')
      a1.add_child('a1a')
      tree.add_child('b')
      tree
    end

    it 'removes all children when max_depth is 0' do
      result = deep_tree.prune(max_depth: 0)
      expect(result).to equal(deep_tree)
      expect(deep_tree.children).to be_empty
      expect(deep_tree.value).to eq('root')
    end

    it 'keeps immediate children but removes grandchildren when max_depth is 1' do
      deep_tree.prune(max_depth: 1)
      expect(deep_tree.children.map(&:value)).to eq(%w[a b])
      a = deep_tree.children.first
      expect(a.children).to be_empty
    end

    it 'keeps grandchildren but removes great-grandchildren when max_depth is 2' do
      deep_tree.prune(max_depth: 2)
      expect(deep_tree.flatten).to eq(%w[root a a1 b])
      a1 = deep_tree.children.first.children.first
      expect(a1.children).to be_empty
    end

    it 'is a no-op when max_depth exceeds the existing height' do
      before = deep_tree.to_h
      deep_tree.prune(max_depth: 99)
      expect(deep_tree.to_h).to eq(before)
    end

    it 'detaches pruned children from their former parent' do
      child = deep_tree.children.first
      deep_tree.prune(max_depth: 0)
      expect(child.parent).to be_nil
    end

    it 'does not modify the receiver value' do
      deep_tree.prune(max_depth: 0)
      expect(deep_tree.value).to eq('root')
    end

    it 'returns self for chaining' do
      expect(deep_tree.prune(max_depth: 1)).to equal(deep_tree)
    end

    it 'raises ArgumentError for negative max_depth' do
      expect { deep_tree.prune(max_depth: -1) }.to raise_error(ArgumentError, /non-negative Integer/)
    end

    it 'raises ArgumentError for non-integer max_depth' do
      expect { deep_tree.prune(max_depth: 1.5) }.to raise_error(ArgumentError, /non-negative Integer/)
      expect { deep_tree.prune(max_depth: '1') }.to raise_error(ArgumentError, /non-negative Integer/)
      expect { deep_tree.prune(max_depth: nil) }.to raise_error(ArgumentError, /non-negative Integer/)
    end
  end
end
