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
end
