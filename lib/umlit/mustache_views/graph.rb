module Umlit
  module MustacheViews
    class Graph < Mustache
      attr_reader :name, :subgraphs, :nodes

      self.template_file = File.join(File.dirname(__FILE__), "graph.mustache")
      def initialize(name = "", subgraphs = [], nodes = [])
        @name = name
        @subgraphs = subgraphs
        @nodes = nodes
      end
    end
  end
end
