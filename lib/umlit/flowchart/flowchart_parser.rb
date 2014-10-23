require "parslet"

module Umlit
  module Flowchart
    class FlowchartParser < Parslet::Parser
      rule(:colon) { spaces? >> str(':') >> spaces? }
      rule(:spaces) { match('\s').repeat(1) }
      rule(:spaces?) { spaces.maybe }
      rule(:eol) { match('\n') }
      rule(:blank_line) { match('[ \t]').repeat >> eol }
      rule(:string) { spaces? >> match('[^\n]').repeat >> eol }

      rule(:comment) { spaces? >> str('#') >> match('[^\n]').repeat >> eol }

      rule(:swimlane) do
        spaces? >> str('<') >> spaces? >>
        match('[^\<\>\n]').repeat.as(:swimlane) >>
        spaces? >> str('>')
      end

      rule(:node) { spaces? >> match('[^\<\>\n]').repeat.as(:name) >> eol }

      rule(:node_line) { swimlane.maybe >> node }

      rule(:flow_break) { str('---') >> eol }

      rule(:decision) do
        spaces >>
        str('(') >> match('[^\)]').repeat.as(:message) >> str(')') >> node_line.as(:node)
      end

      rule(:decision_tree) do
        node_line >> (blank_line | comment | decision.as(:decision)).repeat(1).as(:decisions)
      end

      rule(:title) { str("title") >> colon >> string.as(:title) }

      rule(:top) do
        spaces? >> title.maybe >>
        (blank_line | comment | flow_break.as(:node) | decision_tree.as(:node) | node_line.as(:node)).repeat.as(:nodes)
      end

      root(:top)
    end
  end
end
