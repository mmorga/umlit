module Umlit
  module MustacheViews
    class Union < Mustache
      attr_reader :name, :base

      self.template_path = File.dirname(__FILE__)
      self.template_file = File.join(template_path, "restriction.mustache")
      def initialize(name = "", base = "")
        @name = name
        @base = base
      end
    end
  end
end
