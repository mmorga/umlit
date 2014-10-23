require 'test_helper'

module Umlit
  module Flowchart
    class TestFlowBreak < MiniTest::Unit::TestCase
      def setup
        @flow_break = FlowBreak.new
      end

      def test_attributes
        [:title].each do |attr|
          assert @flow_break.respond_to?(attr), "FlowBreak should have #{attr} reader"
        end
      end
    end
  end
end
