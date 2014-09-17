module Umlit
  module MustacheViews
    class Attribute < Mustache
      attr_reader :name, :value

      def initialize
        @name = ""
        @value = ""
      end
    end
  end
end
