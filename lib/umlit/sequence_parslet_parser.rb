require 'parslet'

module Umlit
  class SequenceParsletParser < Parslet::Parser
    rule(:title)      { str('title') >> space >> string.as(:diagram_title) }
    rule(:activate)   { str('activate') >> space >> identifier.as(:lifeline) }
    rule(:deactivate) { str('deactivate') >> space >> identifier.as(:lifeline) }

    # Operators
    rule(:sync_message)   { str('->') >> space? }
    rule(:async_message)  { str('=>') >> space? }
    rule(:return_message) { str('<-') >> space? }
    rule(:message_type)   { sync_message | async_message | return_message }

    rule(:message_text)   { str(':') >> space >> string.as(:message_text) }
    rule(:message_text?)  { message_text.maybe }

    rule(:space)      { match('\s').repeat(1) }
    rule(:space?)     { space.maybe }
    rule(:string)     { match['a-z'].repeat(1) >> eol }
    rule(:eol)        { match['\n'] }

    # Things
    rule(:integer)    { match('[0-9]').repeat(1).as(:int) >> space? }
    rule(:identifier) { match['a-z'].repeat(1) }

    # Grammar parts
    rule(:message_expression) do
      identifier.as(:source) >> space? >> message_type >> identifier.as(:target) >> space? >> message_text?
    end

    rule(:expression) { title | activate | deactivate | message_expression }

    root :expression
  end
end

parser = Umlit::SequenceParser.new

res = parser.parse("title xyz\na->b:text\n")

puts res.inspect
