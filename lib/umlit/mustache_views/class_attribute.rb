module Umlit
  module MustacheViews
    class ClassAttribute < Mustache
      attr_reader :name, :type

      self.template_path = File.dirname(__FILE__)
      def initialize(name = "", type = "")
        @name = name
        @type = type
      end
    end
  end
end
