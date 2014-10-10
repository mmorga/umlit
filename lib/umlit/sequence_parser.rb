module Umlit
  class SequenceParser
    attr_reader :rowy

    DEFAULT_OPTIONS = { rowy: 100 }
    # Define all of the possible Regexs here to maintain sanity
    MESSAGE_STR = '(.+)'
    TITLE = Regexp.compile("title #{MESSAGE_STR}")

    NODE_CHAR_SET_STR = '\\w\\/'
    NODE_REGEX_UNQUOTED = Regexp.compile("([#{NODE_CHAR_SET_STR}]+)")
    NODE_QUOTED_CHAR_SET_STR = "#{NODE_CHAR_SET_STR}\\:\\s"
    NODE_REGEX_DOUBLE_QUOTED = Regexp.compile("\"([#{NODE_QUOTED_CHAR_SET_STR}]+)\"")
    NODE_REGEX_QUOTED = Regexp.compile("'([#{NODE_QUOTED_CHAR_SET_STR}]+)'")
    NODE_REGEX = Regexp.union(NODE_REGEX_UNQUOTED, NODE_REGEX_DOUBLE_QUOTED, NODE_REGEX_QUOTED)

    MESSAGE_REGEX = Regexp.compile("#{NODE_REGEX}(\\-?-\\>)#{NODE_REGEX}\\:#{MESSAGE_STR}")

    GROUP_REGEX = Regexp.compile("(alt|opt|loop|ref) #{MESSAGE_STR}")
    ELSE_REGEX = Regexp.compile("else\s+#{MESSAGE_STR}?")

    DEACTIVATE_REGEX = Regexp.compile("deactivate #{NODE_REGEX}")
    ACTIVATE_REGEX = Regexp.compile("activate #{NODE_REGEX}")

    NOTE_REGEX = Regexp.compile("note (over|left of|right of) #{NODE_REGEX}(,#{NODE_REGEX})?(\\:#{MESSAGE_STR})?")

    END_NOTE_REGEX = Regexp.compile(/end\s+note\s*/)

    MULTILINE_NOTE_REGEX = Regexp.compile("^ +#{MESSAGE_STR}")

    def initialize(options = {})
      @rowy = DEFAULT_OPTIONS.merge(options)[:rowy]
    end

    def filter_node(node)
      node.sub(/^"/, "").sub(/"$/, "")
    end

    def parse(infile)
      sequence = Umlit::Sequence.new
      depth = 0
      in_note = false
      IO.foreach(infile) do |line|
        if TITLE =~ line
          sequence.title = Regexp.last_match[1]
        elsif MESSAGE_REGEX =~ line
          lnode = filter_node(Regexp.last_match[1..3].compact.first.strip)
          style = Regexp.last_match[4]
          rnode = filter_node(Regexp.last_match[5..7].compact.first.strip)
          msg = Regexp.last_match[8].strip
          sequence.rows << { lnode: lnode, rnode: rnode, message: msg, top: @rowy, style: style == "-->" ? "dashed" : "solid" }
          sequence.actors << lnode unless sequence.actors.include?(lnode)
          sequence.actors << rnode unless sequence.actors.include?(rnode)
          @rowy += 40
        elsif GROUP_REGEX =~ line
          sequence.interactions << {
            type: Regexp.last_match[1].strip,
            message: Regexp.last_match[2].strip,
            start: @rowy,
            elses: [],
            depth: depth }
          depth += 1
          @rowy += 30
        elsif ELSE_REGEX =~ line
          sequence.interactions.last[:elses] << { row: @rowy, message: Regexp.last_match[1].strip }
          @rowy += 35
        elsif line.strip == 'end'
          last = sequence.interactions.size - 1
          last -= 1 while sequence.interactions[last].key?(:end)
          sequence.interactions[last][:end] = @rowy
          @rowy += 15
          depth -= 1
        elsif DEACTIVATE_REGEX =~ line
          node = Regexp.last_match[1..3].compact.first.strip
          sequence.activations[node].last[:end] = @rowy - 30
        elsif ACTIVATE_REGEX =~ line
          node = Regexp.last_match[1..3].compact.first.strip
          sequence.activations[node] = [] unless sequence.activations.key?(node)
          sequence.activations[node] << { start: @rowy - 30 }
        elsif NOTE_REGEX =~ line
          left_message_node = Regexp.last_match[2..4].compact.first
          right_message_node = Regexp.last_match[6..8].compact
          right_message_node = right_message_node.empty? ? left_message_node : right_message_node.first
          sequence.notes << {
            start: @rowy,
            end: @rowy + 25,
            left: left_message_node,
            right: right_message_node,
            messages: Regexp.last_match[10].nil? ? [] : [Regexp.last_match[10].strip],
            position: Regexp.last_match[1].strip
          }
          if !Regexp.last_match[10].nil?
            @rowy += 25
          else
            in_note = true
          end
        elsif END_NOTE_REGEX =~ line
          sequence.notes.last[:end] = @rowy + 5
          @rowy += 10
          in_note = false
        elsif MULTILINE_NOTE_REGEX =~ line
          puts "found multiline or side diagram: #{Regexp.last_match[1]} and in_note = #{in_note}"
          # multiline note or side diagram text
          # notes.last[:message] = "" unless notes.last.has_key?(:message)
          if in_note
            sequence.notes.last[:messages] << Regexp.last_match[1]
          else
            sequence.notes << {
              start: @rowy,
              end: @rowy + 25,
              left: sequence.actors.count - 1,
              right: sequence.actors.count - 1,
              messages: [Regexp.last_match[1]],
              position: "side"
            }
            in_note = true
          end
          @rowy += 25
          sequence.notes.last[:end] = @rowy + 5
        end

        # puts line
      end
      sequence
    end
  end
end
