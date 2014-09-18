module Umlit
  module MustacheViews
    class Subgraph < Mustache
      attr_reader :name, :attributes, :nodes

      self.template_file = File.join(File.dirname(__FILE__), "subgraph.mustache")
      def initialize(name = "", attributes = [], nodes = [])
        @name = name
        @attributes = attributes
        @nodes = nodes
      end
    end
  end
end
