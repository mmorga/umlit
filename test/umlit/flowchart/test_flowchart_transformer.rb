require 'test_helper'

module Umlit
  module Flowchart
    class TestFlowchartTransformer < MiniTest::Unit::TestCase
      def setup
        s = "title: Simple test 1\n\n  # This is my comment\nBox1\n---\n<Swim1>Box2\n  (no) Box3\n  (yes) Box4\nBox3\n"
        parse_tree = FlowchartParser.new.parse(s)
        @transformer = FlowchartTransformer.new
        @result = @transformer.apply(parse_tree)
      end

      def test_node_count
        assert_equal 4, @result[:nodes].count
      end

      def test_flow_break
        assert_equal FlowBreak, @result[:nodes][1].class
      end

      def test_decision
        assert @result[:nodes][2].decisions.all? { |d| d.instance_of?(Decision) }
        assert @result[:nodes][2].decisions.all? { |d| d.target_node.instance_of?(Node) }
      end
    end
  end
end
