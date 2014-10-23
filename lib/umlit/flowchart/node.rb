module Umlit
  module Flowchart
    class Node
      attr_accessor :name, :swimlane, :swimlane_index, :row, :col, :x, :y
      attr_accessor :width, :height, :decisions

      DEFAULT_HASH = { name: "", swimlane: "", decisions: [] }

      def initialize(hash = {})
        hash = DEFAULT_HASH.merge(hash)

        @name = hash[:name]
        @swimlane = hash[:swimlane]
        @decisions = hash[:decisions].map { |d| Decision.new(d[:decision]) }

        @swimlane_index = nil
        @row = 0
        @col = 0
        @x = 0
        @y = 0
        @width = 0
        @height = 0
      end
    end
  end
end
