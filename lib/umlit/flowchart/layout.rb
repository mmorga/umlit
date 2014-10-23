module Umlit
  module Flowchart
    # 1. Read the parse tree and determine the total number of swimlanes and nodes
    # 2. Build a sparse 2-dimensional array of swimlanes to nodes.
    # 3. Start with the first node
    # 4. Place it in its swimlane and at position zero
    # 6. Repeat for each node
    #
    # Placement:
    # 1. If node is already placed:
    #    a. add line from previous node to this node
    #    b. done
    # 2. If node isn't placed:
    #    a. If node is in same swimlane:
    #       1. Place node in next position in swimlane row.
    #       2. If that position is occupied, make the content of that position an array and add this node to it
    #    b. If node is in diff swimlane:
    #       1. Place node in same position in it's swimlane row.
    #       2. If that position is occupied, try the one to the right.
    # 3. add line from previous node to this node
    # 4. If it has decisions
    #    a. mark space as a decision (diamond shape)
    #    b. place each decision node
    class Layout
      attr_accessor :swimlanes, :nodes, :layout, :parse_tree

      def initialize
        @swimlanes = []
        @nodes = []
        @layout = nil
        @x = 0
        @last_swimlane = 0
      end

      def import_node(node)
        swimlanes.push(node[:swimlane]) if node.include?(:swimlane)
        nodes.push(node[:node]) if node.include?(:node)
      end

      def parse(parse_tree)
        @parse_tree = parse_tree
        parse_tree[:nodes].each do |node|
          import_node(node)
          next unless node.include?(:decisions)
          node[:decisions].each do |decision|
            import_node(decision)
          end
        end
        @nodes.uniq!
        @swimlanes.uniq!
      end

      def layout_node(node)
        next_swimlane = @last_swimlane
        next_swimlane = swimlanes.index(node[:swimlane]) if node.include?(:swimlane)
        puts "#{next_swimlane.inspect}, #{node[:swimlane]}"
        @x += 1 unless next_swimlane != @last_swimlane
        @layout[next_swimlane][@x] = node[:node]
        @last_swimlane = next_swimlane
      end

      def do_layout
        @layout = Array.new(swimlanes.count)
        (0..swimlanes.count).each { |i| @layout[i] = Array.new(nodes.count + 1, "") }
        swimlanes.each_with_index { |s, i| @layout[i][0] = s }
        @x = 0
        @last_swimlane = 0
        parse_tree[:nodes].each do |node|
          layout_node(node)
          next unless node.include?(:decisions)
          node[:decisions].each do |decision|
            layout_node(decision)
          end
        end
      end
    end
  end
end
