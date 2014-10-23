require 'test_helper'

module Umlit
  module Flowchart
    class TestFlowchartParser < MiniTest::Test
      def setup
        @parser = FlowchartParser.new
      end

      def test_eol
        assert @parser.eol.parse("\n")
      end

      def test_spaces
        assert @parser.spaces.parse(" ")
        assert @parser.spaces.parse("  ")
        assert @parser.spaces.parse("  \t  \n")
      end

      def test_spaces?
        assert @parser.spaces?.parse(" ")
        assert @parser.spaces?.parse("  ")
        assert @parser.spaces?.parse("  \t  \n")
        assert @parser.spaces?.parse("")
      end

      def test_comment
        assert @parser.comment.parse("# nskl 08 -+!@#$%^&*()\n")
        assert @parser.comment.parse("   # nskl 08 -+!@#$%^&*()   \n")
      end

      def test_blank_line
        assert @parser.blank_line.parse("     \n")
        assert @parser.blank_line.parse("\n")
        assert @parser.blank_line.parse("  \t  \t\n")
      end

      def test_colon
        assert @parser.colon.parse(":")
        assert @parser.colon.parse("  :  ")
      end

      def test_string
        result = @parser.string.parse(" This is a simple string  \n")
        assert_equal(result.to_s.strip, "This is a simple string")
      end

      def test_title
        assert_equal "This is my title", @parser.title.parse("title: This is my title\n")[:title].to_s.strip
      end

      def test_swimlane
        assert_equal "AB/Swim Lane", @parser.swimlane.parse("<AB/Swim Lane>")[:swimlane].to_s.strip
      end

      def test_node
        assert_equal "Do Something", @parser.node.parse(" Do Something \n")[:name].to_s.strip
      end

      def test_node_line
        assert_equal({ swimlane: "AB/Swim Lane", name: "In this step I do something" },
                     @parser.node_line.parse("<AB/Swim Lane> In this step I do something\n"))
      end

      def test_flow_break
        assert @parser.flow_break.parse("---\n")
      end

      def test_decision
        assert_equal({ message: "no", node: { name: "Some box to go to" } },
                     @parser.decision.parse("  (no) Some box to go to\n"))
        assert_equal({ message: "no", node: { name: "Some box to go to", swimlane: "swimmer" } },
                     @parser.decision.parse("  (no) <swimmer> Some box to go to\n"))
      end

      def test_decision_tree
        assert_equal(
          {
            name: "box1?",
            decisions: [
              { decision: { message: "no", node: { name: "Some box to go to" } } },
              { decision: { message: "yes", node: { name: "Some other box to go to" } } }]
          },
          @parser.decision_tree.parse("box1?\n  (no) Some box to go to\n  (yes) Some other box to go to\n"))
      end

      def test_top_empty
        assert @parser.top.parse("\n\n")
      end

      def test_top_title_only
        assert @parser.top.parse("title: Simple test 1\n\n")
      end

      def test_top_node_only
        assert @parser.top.parse("Box1\n")
      end

      def test_top_several_nodes_and_comment
        assert_equal(
          {
            title: "Simple test 1\n",
            nodes: [
              { node: { name: "Box1" } },
              { node: "---\n" },
              { node: { swimlane: "Swim1", name: "Box2" } },
              { node: { name: "Box3" } }
            ]
          },
          @parser.top.parse("title: Simple test 1\n\n  # This is my comment\nBox1\n---\n<Swim1>Box2\nBox3\n"))
      end

      def test_top_several_nodes_with_decision_tree
        assert_equal({ title: "Simple test 2\n",
                       nodes: [
                         { node: { name: "Box1?", decisions: [{ decision: { message: "no", node: { swimlane: "Swim1", name: "Box2" } } },
                                                              { decision: { message: "yes", node: { name: "Box3" } } }] } },
                         { node: { swimlane: "Swim1", name: "Box2" } },
                         { node: { name: "Box3" } }]
                      },
                     @parser.top.parse(
                      "title: Simple test 2\nBox1?\n  (no) <Swim1>Box2\n  (yes) Box3\n<Swim1>Box2\nBox3\n"))
      end
    end
  end
end
