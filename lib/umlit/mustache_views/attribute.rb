module Umlit
  module MustacheViews
    class Attribute < Mustache
      attr_reader :name, :value

      self.template_path = File.dirname(__FILE__)
      self.template_file = File.join(template_path, "attribute.mustache")
      def initialize(name = "", value = "")
        @name = name
        @value = case value[0]
                 when "<"
                   "<#{value}>"
                 when "\""
                   value
                 else
                   "\"#{value}\""
        end
      end
    end
  end
end
