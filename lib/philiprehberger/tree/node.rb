# frozen_string_literal: true

module Philiprehberger
  module Tree
    # A generic tree node with traversal, search, and serialization.
    class Node
      # @return [Object] the value stored in this node
      attr_reader :value

      # @return [Array<Node>] child nodes
      attr_reader :children

      # @return [Node, nil] parent node (nil for root)
      attr_reader :parent

      # Create a new tree node.
      #
      # @param value [Object] the value to store
      def initialize(value)
        @value = value
        @children = []
        @parent = nil
      end

      # Add a child node with the given value.
      #
      # @param value [Object] value for the new child node
      # @return [Node] the newly created child node
      def add_child(value)
        child = value.is_a?(Node) ? value : Node.new(value)
        child.instance_variable_set(:@parent, self)
        @children << child
        child
      end

      # Remove a child node by value.
      #
      # @param value [Object] value of the child to remove
      # @return [Node, nil] the removed child node, or nil if not found
      def remove_child(value)
        index = @children.index { |c| c.value == value }
        return nil unless index

        child = @children.delete_at(index)
        child.instance_variable_set(:@parent, nil)
        child
      end

      # Check if this node is the root (has no parent).
      #
      # @return [Boolean]
      def root?
        @parent.nil?
      end

      # Check if this node is a leaf (has no children).
      #
      # @return [Boolean]
      def leaf?
        @children.empty?
      end

      # Return the depth of this node (distance from root).
      #
      # @return [Integer]
      def depth
        node = self
        d = 0
        while node.parent
          d += 1
          node = node.parent
        end
        d
      end

      # Return the height of the subtree rooted at this node.
      #
      # @return [Integer]
      def height
        return 0 if leaf?

        1 + @children.map(&:height).max
      end

      # Return the total number of nodes in the subtree rooted at this node.
      #
      # @return [Integer]
      def size
        1 + @children.sum(&:size)
      end

      # Iterate depth-first (pre-order) over the subtree.
      #
      # @yield [Node] each node in depth-first order
      # @return [Enumerator] if no block given
      def each_dfs(&block)
        return enum_for(:each_dfs) unless block

        block.call(self)
        @children.each { |child| child.each_dfs(&block) }
      end

      # Iterate breadth-first over the subtree.
      #
      # @yield [Node] each node in breadth-first order
      # @return [Enumerator] if no block given
      def each_bfs(&block)
        return enum_for(:each_bfs) unless block

        queue = [self]
        until queue.empty?
          node = queue.shift
          block.call(node)
          queue.concat(node.children)
        end
      end

      # Find the first node matching the block.
      #
      # @yield [Node] predicate block
      # @return [Node, nil] the first matching node, or nil
      def find(&block)
        return nil unless block

        each_dfs { |node| return node if block.call(node) }
        nil
      end

      # Return the path from root to the first node with the given value.
      #
      # @param value [Object] value to search for
      # @return [Array<Node>, nil] array of nodes from root to target, or nil if not found
      def path_to(value)
        target = find { |n| n.value == value }
        return nil unless target

        path = []
        node = target
        while node
          path.unshift(node)
          node = node.parent
        end
        path
      end

      # Return all leaf nodes in the subtree.
      #
      # @return [Array<Node>]
      def leaves
        each_dfs.select(&:leaf?)
      end

      # Serialize the subtree to a hash.
      #
      # @return [Hash] hash with :value and :children keys
      def to_h
        {
          value: @value,
          children: @children.map(&:to_h)
        }
      end

      # Print a visual representation of the tree.
      #
      # @param indent [String] prefix for indentation (used internally)
      # @param last [Boolean] whether this is the last sibling (used internally)
      # @return [String] the tree as a formatted string
      def print_tree(indent: '', last: true)
        lines = []
        connector = root? ? '' : (last ? '└── ' : '├── ')
        lines << "#{indent}#{connector}#{@value}"

        child_indent = indent + (root? ? '' : (last ? '    ' : '│   '))
        @children.each_with_index do |child, i|
          lines << child.print_tree(indent: child_indent, last: i == @children.size - 1)
        end

        lines.join("\n")
      end
    end
  end
end
