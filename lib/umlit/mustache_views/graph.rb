module Umlit
  module MustacheViews
    class Graph < Mustache
      attr_reader :name, :subgraphs, :nodes

      def initialize
        @name = ""
        @subgraphs = []
        @nodes = []
      end
    end
  end
end
