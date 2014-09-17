module Umlit
  module MustacheViews
    class Node < Mustache
      attr_reader :name, :attributes

      def initialize
        @name = ""
        @subgraphs = []
        @nodes = []
      end
    end

    class EdgeNode < Node
      attr_reader :from, :to

      def initialize
        @from = ""
        @to = ""
      end

      def name
        "#{from} -> #{to}"
      end
    end
  end
end
