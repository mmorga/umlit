module Umlit
  module MustacheViews
    class Subgraph < Mustache
      attr_reader :name, :attributes, :nodes

      def initialize
        @name = ""
        @attributes = []
        @nodes = []
      end
    end
  end
end
