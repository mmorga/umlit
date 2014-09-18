module Umlit
  module MustacheViews
    class Node < Mustache
      attr_reader :name, :attributes

      # self.template_file = File.join(File.dirname(__FILE__), "node.mustache")
      # self.template_path = File.join(File.dirname(__FILE__), "../../..")
      self.template_path = File.dirname(__FILE__)
      def initialize(name = "", attributes = {})
        @name = name
        @attributes = attributes.map { |k, v| Attribute.new(k, v) }
      end

      def attribute_list
        @attributes.map(&:render).join(",")
      end
    end

    class EdgeNode < Node
      attr_reader :from, :to, :name

      def initialize(from = "", to = "", attributes = {})
        @from = from
        @to = to
        super("#{from} -> #{to}", attributes)
      end

      def name
        "#{from} -> #{to}"
      end
    end
  end
end
