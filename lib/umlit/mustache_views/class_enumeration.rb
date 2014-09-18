module Umlit
  module MustacheViews
    class ClassEnumeration < Mustache
      attr_reader :value

      self.template_path = File.dirname(__FILE__)
      def initialize(value = "")
        @value = value
      end
    end
  end
end
