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

      # Remove all descendants deeper than `max_depth` levels below the receiver.
      #
      # `prune(max_depth: 0)` removes every child, `prune(max_depth: 1)` keeps
      # immediate children but removes grandchildren, and so on. Mutates in
      # place; the receiver's own value is never touched.
      #
      # @param max_depth [Integer] non-negative retention depth
      # @return [self] for chaining
      # @raise [ArgumentError] if max_depth is not a non-negative Integer
      def prune(max_depth:)
        unless max_depth.is_a?(Integer) && max_depth >= 0
          raise ArgumentError, "max_depth must be a non-negative Integer (got #{max_depth.inspect})"
        end

        if max_depth.zero?
          @children.each { |c| c.instance_variable_set(:@parent, nil) }
          @children.clear
        else
          @children.each { |child| child.prune(max_depth: max_depth - 1) }
        end
        self
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

      # Iterate depth-first (post-order) over the subtree.
      # Children are visited before the parent.
      #
      # @yield [Node] each node in depth-first post-order
      # @return [Enumerator] if no block given
      def each_post_order(&block)
        return enum_for(:each_post_order) unless block

        @children.each { |child| child.each_post_order(&block) }
        block.call(self)
      end

      # Return a deep copy of this node and all descendants, detached from parent.
      #
      # @return [Node] a new tree rooted at a copy of this node
      def subtree
        copy = Node.new(@value)
        @children.each do |child|
          child_copy = child.subtree
          child_copy.instance_variable_set(:@parent, copy)
          copy.children << child_copy
        end
        copy
      end

      # Structural equality: same value, same number of children,
      # and children are recursively equal.
      #
      # @param other [Node] the node to compare with
      # @return [Boolean]
      def ==(other)
        return false unless other.is_a?(Node)
        return false unless @value == other.value
        return false unless @children.size == other.children.size

        @children.zip(other.children).all? { |a, b| a == b }
      end

      # Return an array of ancestor nodes from parent up to root.
      #
      # @return [Array<Node>] ancestors from parent to root (empty for root)
      def ancestors
        result = []
        node = @parent
        while node
          result << node
          node = node.parent
        end
        result
      end

      # Return sibling nodes (children of the same parent, excluding self).
      #
      # @return [Array<Node>] sibling nodes (empty for root)
      def siblings
        return [] unless @parent

        @parent.children.reject { |c| c.equal?(self) }
      end

      # Return the next sibling in the parent's child order.
      #
      # @return [Node, nil] the next sibling, or nil if this is the last child or has no parent
      def next_sibling
        return nil unless @parent

        index = @parent.children.index { |c| c.equal?(self) }
        return nil unless index

        @parent.children[index + 1]
      end

      # Return the previous sibling in the parent's child order.
      #
      # @return [Node, nil] the previous sibling, or nil if this is the first child or has no parent
      def prev_sibling
        return nil unless @parent

        index = @parent.children.index { |c| c.equal?(self) }
        return nil if index.nil? || index.zero?

        @parent.children[index - 1]
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

      # Find the first node whose value matches the given value (==).
      #
      # @param value [Object] value to search for
      # @return [Node, nil] the first matching node, or nil
      def find_by_value(value)
        find { |n| n.value == value }
      end

      # Check whether any node in the subtree has the given value.
      #
      # @param value [Object] value to search for
      # @return [Boolean]
      def include?(value)
        !find_by_value(value).nil?
      end

      # Return all nodes in the subtree matching the predicate block.
      #
      # @yield [Node] predicate block
      # @return [Array<Node>] all matching nodes (empty if none or no block)
      def select(&block)
        return [] unless block

        each_dfs.select(&block)
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

      # Return every path from the receiver to each leaf in its subtree.
      #
      # Each element is an array of nodes starting at the receiver and ending
      # at a leaf, in depth-first pre-order by leaf. A leaf receiver returns
      # `[[self]]`.
      #
      # @return [Array<Array<Node>>] paths, each as an array of nodes
      def paths
        return [[self]] if leaf?

        result = []
        @children.each do |child|
          child.paths.each { |sub_path| result << ([self] + sub_path) }
        end
        result
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

      # Reconstruct a tree from a hash (inverse of #to_h).
      #
      # @param hash [Hash] hash with :value and :children keys
      # @return [Node] the reconstructed tree
      def self.from_h(hash)
        node = new(hash[:value])
        (hash[:children] || []).each do |child_hash|
          child = from_h(child_hash)
          child.instance_variable_set(:@parent, node)
          node.children << child
        end
        node
      end

      # Return a new tree with the same structure but transformed values.
      #
      # @yield [Object] the value of each node
      # @return [Node] a new tree with mapped values
      def map(&block)
        mapped = Node.new(block.call(@value))
        @children.each do |child|
          child_mapped = child.map(&block)
          child_mapped.instance_variable_set(:@parent, mapped)
          mapped.children << child_mapped
        end
        mapped
      end

      # Return all values as a flat array in depth-first pre-order.
      #
      # @return [Array] all node values
      def flatten
        each_dfs.map(&:value)
      end

      # Iterate depth-first yielding each node with its depth level.
      #
      # @yield [Node, Integer] each node and its depth
      # @return [Enumerator] if no block given
      def each_with_depth(current_depth = 0, &block)
        return enum_for(:each_with_depth, current_depth) unless block

        block.call(self, current_depth)
        @children.each { |child| child.each_with_depth(current_depth + 1, &block) }
      end

      # Print a visual representation of the tree.
      #
      # @param indent [String] prefix for indentation (used internally)
      # @param last [Boolean] whether this is the last sibling (used internally)
      # @return [String] the tree as a formatted string
      def print_tree(indent: '', last: true)
        lines = []
        connector = if root?
                      ''
                    else
                      (last ? '└── ' : '├── ')
                    end
        lines << "#{indent}#{connector}#{@value}"

        child_indent = indent + (if root?
                                   ''
                                 else
                                   (last ? '    ' : '│   ')
                                 end)
        @children.each_with_index do |child, i|
          lines << child.print_tree(indent: child_indent, last: i == @children.size - 1)
        end

        lines.join("\n")
      end
    end
  end
end
