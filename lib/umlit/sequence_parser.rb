module Umlit
  class SequenceParser
    attr_reader :rowy

    DEFAULT_OPTIONS = { rowy: 100 }

    def initialize(options = {})
      @rowy = DEFAULT_OPTIONS.merge(options)[:rowy]
    end

    def parse(infile)
      sequence = Umlit::Sequence.new
      depth = 0
      in_note = false
      IO.foreach(infile) do|line|
        if  /title (.+)/ =~ line
          sequence.title = Regexp.last_match[1]
          # @rowy += 15
        elsif /([a-zA-Z0-9]+)(\-?-\>)(.+)\:(.+)/ =~ line
          lnode = Regexp.last_match[1].strip
          style = Regexp.last_match[2]
          rnode = Regexp.last_match[3].strip
          msg = Regexp.last_match[4].strip
          sequence.rows << { lnode: lnode, rnode: rnode, message: msg, top: @rowy, style: style == "-->" ? "dashed" : "solid" }
          sequence.actors << lnode unless sequence.actors.include?(lnode)
          sequence.actors << rnode unless sequence.actors.include?(rnode)
          @rowy += 40
        elsif /(alt|opt|loop|ref) (.+)/ =~ line
          sequence.interactions << {
            type: Regexp.last_match[1].strip,
            message: Regexp.last_match[2].strip,
            start: @rowy,
            elses: [],
            depth: depth }
          depth += 1
          @rowy += 20
        elsif /else (.+)/ =~ line
          sequence.interactions.last[:elses] << { row: @rowy, message: Regexp.last_match[1].strip }
          @rowy += 20
        elsif line.strip == 'end'
          last = sequence.interactions.size - 1
          last -= 1 while sequence.interactions[last].key?(:end)
          sequence.interactions[last][:end] = @rowy
          @rowy += 15
          depth -= 1
        elsif /deactivate (.+)/ =~ line
          node = Regexp.last_match[1].strip
          sequence.activations[node].last[:end] = @rowy - 30
        elsif /activate (.+)/ =~ line
          node = Regexp.last_match[1].strip
          sequence.activations[node] = [] unless sequence.activations.key?(node)
          sequence.activations[node] << { start: @rowy - 30 }
        elsif /note (over|left of|right of) ([a-zA-Z0-9,]+)(\:(.+))?/ =~ line
          note_nodes = Regexp.last_match[2].strip.split(",")
          sequence.notes << {
            start: @rowy,
            end: @rowy + 20,
            left: note_nodes.first.strip,
            right: note_nodes.last.strip,
            messages: Regexp.last_match[4].nil? ? [] : [Regexp.last_match[4].strip],
            position: Regexp.last_match[1].strip
          }
          if !Regexp.last_match[4].nil?
            @rowy += 25
          else
            in_note = true
          end
        elsif /end note/ =~ line
          sequence.notes.last[:end] = @rowy + 5
          @rowy += 10
          in_note = false
        elsif /^ +(.+)/ =~ line
          # multiline note or side diagram text
          # notes.last[:message] = "" unless notes.last.has_key?(:message)
          if in_note
            sequence.notes.last[:messages] << Regexp.last_match[1]
          else
            # do something
          end
          @rowy += 10
        end

        # puts line
      end
      sequence
    end
  end
end
