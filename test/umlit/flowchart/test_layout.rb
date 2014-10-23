require 'test_helper'

module Umlit
  module Flowchart
    class TestLayout < MiniTest::Test
      def setup
        s = "<Swim0>Box1\nBox1a\n<Swim1>Box2\n  (no) Box3\n  (yes) Box4\nBox3\n"
        parse_tree = FlowchartParser.new.parse(s)
        parse_tree = FlowchartTransformer.new.apply(parse_tree)
        @result = SwimlaneAssigner.new.assign_swimlanes(parse_tree)
        @layout = Layout.new
      end

      def test_assign_swimlanes
        assert_equal "Swim0", @result[:nodes][0].swimlane
        assert_equal "Swim0", @result[:nodes][1].swimlane
        assert_equal "Swim1", @result[:nodes][2].swimlane
        assert @result[:nodes][2].decisions.all? { |d| d.target_node.swimlane == "Swim1" },
               "All decisions for node 2 should be Swim1"
        assert_equal "Swim1", @result[:nodes][3].swimlane
      end
    end
  end
end
