require 'test_helper'

module Umlit
  module Flowchart
    class TestDecision < MiniTest::Test
      def setup
        @decision = Decision.new(node: Node.new(name: "Node Name"), message: "hola")
      end

      def test_attributes
        [:target_node, :message].each do |attr|
          assert @decision.respond_to?(attr), "Decision should have #{attr} reader"
        end
      end

      def test_initialize
        assert_equal "Node Name", @decision.target_node.name
        assert_equal "hola", @decision.message
      end
    end
  end
end
