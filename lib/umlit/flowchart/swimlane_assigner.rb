module Umlit
  module Flowchart
    # The SwimlaneAssigner runs through the parsetree and sets the swimlane for
    # all nodes based on the order of access.
    class SwimlaneAssigner
      def initialize
        @current_swimlane = ""
      end

      def process_node(node)
        if node.swimlane.to_s.empty?
          node.swimlane = @current_swimlane
        else
          @current_swimlane = node.swimlane
        end
      end

      # This should be a transformed parse tree
      def assign_swimlanes(parse_tree)
        parse_tree[:nodes].each do |node|
          process_node(node)
          node.decisions.each do |d|
            # For decisions, the current node is all that matters
            d.target_node.swimlane = node.swimlane if d.target_node.swimlane.to_s.empty?
          end
        end
        parse_tree
      end
    end
  end
end
