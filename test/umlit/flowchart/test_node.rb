require 'test_helper'

module Umlit
  module Flowchart
    class TestNode < MiniTest::Unit::TestCase
      def setup
        @node = Node.new(swimlane: "Swim1", name: "Box2", decisions: [
          { decision: { message: "yes", node: { name: "Box3" } } },
          { decision: { message: "no", node: { name: "Box4" } } }])
      end

      def test_attributes
        [:name, :swimlane, :swimlane_index, :row, :col, :x, :y,
         :width, :height, :decisions].each do |attr|
          assert @node.respond_to?(attr), "Node should have #{attr} reader"
        end
      end

      def test_initialize
        assert_equal "Box2", @node.name
        assert_equal "Swim1", @node.swimlane
        assert_equal 2, @node.decisions.count
        assert @node.decisions.all? { |d| d.instance_of?(Decision) }
      end
    end
  end
end
