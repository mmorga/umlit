module Umlit
  module MustacheViews
    class SimpleType < Mustache
      attr_reader :specialization_font_attributes, :specialization
      attr_reader :restrictions, :types, :enumerations

      self.template_path = File.dirname(__FILE__)
      self.template_file = File.join(template_path, "simple_type.mustache")

      DEFAULT_OPTS = {
        specialization_font_attributes: { face: "Helvetica-Bold" }
      }

      def initialize(specialization = "", restrictions = [], types = [], enumerations = [])
        @specialization = specialization
        @restrictions = restrictions.map { |v| ClassEnumeration.new(v) }
        @types = types.map { |v| ClassEnumeration.new(v) }
        @enumerations = enumerations.map { |v| ClassEnumeration.new(v) }

        options = DEFAULT_OPTS
        @specialization_font_attributes = hash_to_html_options(options[:specialization_font_attributes])
      end

      def hash_to_html_options(h)
        h.reduce("") { |a, e| "#{a} #{e.first}=\"#{e.last}\"" }
      end

      def restrictions?
        !restrictions.empty?
      end

      def types?
        !types.empty?
      end

      def enumerations?
        !enumerations.empty?
      end

      def row_count
        types.count + restrictions.count + 1
      end
    end
  end
end
