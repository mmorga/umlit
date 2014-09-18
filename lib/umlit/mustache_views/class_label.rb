module Umlit
  module MustacheViews
    class ClassLabel < Mustache
      attr_reader :name, :table_attributes, :stereotype_font_attributes
      attr_reader :stereotype, :title_font_attributes, :attributes, :methods
      attr_reader :lines

      self.template_path = File.dirname(__FILE__)
      self.template_file = File.join(template_path, "class_label.mustache")

      DEFAULT_OPTS = {
        table_attributes: { cellspacing: "0", cellborder: "0" },
        stereotype_font_attributes: { "point-size" => "10" },
        title_font_attributes: { face: "Helvetica-Bold" }
      }

      def initialize(name = "", stereotype = "", attributes = {}, methods = [], opts = {})
        @name = name
        @stereotype = stereotype
        @attributes = attributes.map { |k, v| ClassAttribute.new(k, v) }
        @methods = methods
        @lines = []

        options = DEFAULT_OPTS.merge(opts)
        @table_attributes = hash_to_html_options(options[:table_attributes])
        @stereotype_font_attributes = hash_to_html_options(options[:stereotype_font_attributes])
        @title_font_attributes = hash_to_html_options(options[:title_font_attributes])
      end

      def hash_to_html_options(h)
        h.reduce("") { |a, e| "#{a} #{e.first}=\"#{e.last}\"" }
      end

      def attributes?
        !attributes.empty?
      end

      def methods?
        !methods.empty?
      end
    end
  end
end
