require 'builder'

module Umlit
  # TODO:
  # 1. Separate calculations from rendering
  # 2. Render using builder
  # 3. Separate out style
  # 4. Fix rowy dependency
  class SequenceRenderer
    attr_accessor :diagram_width, :diagram_height, :rowy, :theme
    attr_reader :sequence, :actor_text, :message_text

    def initialize
      @diagram_width = 0
      @diagram_height = 0
      @rowy = 0
      @theme = 'default'
      @actor_widths = []
      @actor_mid_points = []
      @actor_spacing = []
    end

    def render(sequence)
      @sequence = sequence
      @actor_text = Umlit::Text.new(font_weight: Magick::BoldWeight)
      @message_text = Umlit::Text.new

      # Calculate Positions based on Actor width
      sequence.actors.each_with_index do |node, idx|
        metrics = actor_text.metrics(node)
        @actor_widths << (metrics.width + metrics.max_advance * 3)
        mid_point = @actor_widths[idx] / 2
        x = mid_point
        x = x + @actor_mid_points[idx - 1] + 20 + (@actor_widths[idx - 1] / 2) if idx > 0
        @actor_mid_points << x
        @actor_spacing[idx] ||= 0
        @actor_spacing[idx] = @actor_spacing[idx] + mid_point
        @actor_spacing[idx + 1] = mid_point + 10
        # puts "Initial actor spacing #{@actor_spacing[idx].inspect}"
      end

      # Adjust spacing based on Message width
      sequence.rows.each do |row|
        metrics = message_text.metrics(row[:message])
        x1 = @actor_mid_points[sequence.actors_index(row[:lnode])]
        x2 = @actor_mid_points[sequence.actors_index(row[:rnode])]
        next if (x2 - x1).abs >= (metrics.width + metrics.max_advance * 3)

        # puts "Message is too long row #{row[:message]} between #{row[:lnode]} and #{row[:rnode]}"
        l_idx, r_idx = [sequence.actors_index(row[:lnode]), sequence.actors_index(row[:rnode])].sort
        steps = (l_idx - r_idx).abs
        steps = 1 if steps == 0
        new_width = (metrics.width) / steps + metrics.max_advance * 3
        # puts "Setting for message '#{row[:message]}' (width: #{metrics.width}) spacing between #{row[:lnode]} and #{row[:rnode]} to #{new_width}"
        (l_idx..r_idx).each { |i| @actor_spacing[i + 1] = new_width if @actor_spacing[i + 1] < new_width }
      end

      @actor_mid_points.each_with_index do |_mp, i|
        @actor_mid_points[i] = @actor_spacing[i]
        @actor_mid_points[i] = @actor_mid_points[i] + @actor_mid_points[i - 1] if i > 0
        # puts @actor_mid_points[i]
      end

      @diagram_width = @actor_mid_points.last + @actor_spacing.last
      @diagram_height = rowy + 55

      draw_svg
    end

    def draw_svg
      svg_content = Builder::XmlMarkup.new(indent: 2)
      svg_content.instruct! :xml, version: "1.0", encoding: "UTF-8", standalone: "no"
      svg_content.declare! :DOCTYPE, :svg, :PUBLIC, "-//W3C//DTD SVG 1.1//EN",
                           "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"
      svg_content.svg(width: diagram_width, height: diagram_height,
                      viewBox: "0 0 #{diagram_width} #{diagram_height}",
                      xmlns: "http://www.w3.org/2000/svg",
                      "xmlns:xlink" => "http://www.w3.org/1999/xlink") do |svg|
        draw_defs(svg)
        svg.title(sequence.title)
        svg.rect(x: 0, y: 0, width: diagram_width, height: diagram_height, fill: 'white', stroke: 'none')
        draw_actors_lifelines(svg)
        draw_messages(svg)
        draw_activations(svg)
        draw_interactions(svg)
        draw_notes(svg)
      end
      svg_content.target!
    end

    def draw_defs(svg)
      svg.defs do |defs|
        defs.style(style)
        defs.marker(orient: "auto", id: "FilledArrow_Marker",
                    style: "color:#000;overflow:visible", refX: "0",
                    refY: "0") do |marker|
          marker.path(d: "M 10.0,0.0 L 10.0,-12.0 L -20,0.0 L 10.0,12.0 L 10.0,0.0 z",
                      id: "solid-arrow-head",
                      style: "fill-rule:evenodd;fill:currentColor;stroke:none;stroke-width:1;stroke-dasharray:none;",
                      transform: "scale(0.5) rotate(180) translate(20,0)")
        end
        defs.marker(orient: "auto", id: "OpenArrow_Marker",
                    style: "color:#000;overflow:visible", refX: "0",
                    refY: "0") do |marker|
          marker.path(d: "M 10.0,-12.0 L -20,0.0 L 10.0,12.0",
                      id: "open-arrow-head",
                      style: "stroke:currentColor;stroke-width:1;stroke-dasharray:none;",
                      transform: "scale(0.5) rotate(180) translate(20,0)")
        end
      end
    end

    def draw_actors_lifelines(svg)
      actor_height = 36
      mid_height = actor_height / 2
      sequence.actors.each_with_index do |node, idx|
        mid_point = @actor_widths[idx] / 2
        x = @actor_mid_points[idx]
        svg.rect(x: x - mid_point, y: 0, width: @actor_widths[idx], height: actor_height, class: 'participant-box')
        svg.text(node, textLength: actor_text.width(node), x: x, y: mid_height, class: "participant", "text-anchor" => "middle")
        svg.line(x1: x, y1: actor_height, x2: x, y2: rowy, class: 'participant-line')
      end
    end

    def draw_messages(svg)
      sequence.rows.each do |row|
        y = row[:top]
        x1 = @actor_mid_points[sequence.actors_index(row[:lnode])]
        x2 = @actor_mid_points[sequence.actors_index(row[:rnode])]
        svg.text(row[:message], textLength: message_text.width(row[:message]), x: (x1 < x2 ? x1 : x2) + 5, y: y, class: 'message')
        if row[:style] == "dashed"
          style = { "stroke-dasharray" => "4,4" }
          path_class = "reply"
        else
          style = {}
          path_class = "signal"
        end
        y += 10
        if row[:lnode] == row[:rnode]
          svg.path(style.merge(d: "M #{x1},#{y} l 50.0,0 l 0.0,15 l -50.0,0.0", class: path_class))
        else
          svg.line(style.merge(x1: x1, y1: y, x2: x2, y2: y, class: path_class))
        end
      end
    end

    def draw_activations(svg)
      sequence.activations.each do |node, acts|
        x = @actor_mid_points[sequence.actors_index(node)] - 5
        acts.each do|act|
          y = act[:start]
          width = 10
          height = (act[:end] - act[:start])
          svg.rect(x: x, y: y, width: width, height: height, class: 'activation-box')
        end
      end
    end

    def draw_interactions(svg)
      sequence.interactions.each do |box|
        x1 = box[:depth] * 10
        width = diagram_width - (box[:depth] * 20)
        y1 = box[:start]
        height = box[:end] - box[:start]
        svg.rect(x: x1, y: y1, width: width, height: height, class: 'group-box')
        svg.path(d: "M #{x1}, #{y1 + 15} l 25.0,0 l 5.0,-5.0 l 0.0,-10.0 l -30.0,0 z", class: 'group-box-title')
        svg.text(box[:type], x: x1 + 5, y: y1 + 12, class: 'group')
        svg.text(box[:message], x: x1 + 40, y: y1 + 12, class: 'group')
        box[:elses].each do|else_item|
          ey = else_item[:row]
          svg.line(x1: x1, y1: ey, x2: width, y2: ey, "stroke-dasharray" => '4,4')
          svg.text("[#{else_item[:message]}]", x: x1 + 40, y: ey + 10, class: 'group')
        end
      end
    end

    def draw_notes(svg)
      sequence.notes.each do |note|
        # :start, :end, :left (node name), :right (node name), :message, :position (over, left of or right of)
        leftidx, rightidx = [sequence.actors_index(note[:left]), sequence.actors_index(note[:right])].sort

        if note[:position] == 'over'
          x = @actor_mid_points[leftidx] - @actor_spacing[leftidx] / 2
          width = @actor_mid_points[rightidx] + (@actor_spacing[rightidx + 1] / 2) - x
        elsif note[:position] == 'right of'
          x = @actor_mid_points[rightidx] + 15
          width = @actor_spacing[rightidx + 1] - 30
        elsif note[:position] == 'left of'
          x = @actor_mid_points[leftidx] - @actor_spacing[leftidx] + 15
          width = @actor_spacing[leftidx] - 30
        end
        y1 = note[:start]
        y2 = note[:end]

        width = 90 if width <= 50 # TODO
        svg.path(d: "M #{x},#{y1} l #{width - 5},0 l 5,5 l -5,0 l 0,-5, l 5,5 l 0,#{y2 - y1 - 5} l #{-width},0 z", class: 'note-box')
        y1 += 3
        note[:messages].each do|message|
          y1 += 10
          svg.text(message, x: x + 5, y: y1, class: 'note')
        end
      end
    end

    def load_theme_file(file)
      theme_file = File.join(File.dirname(__FILE__), "..", "..", "themes", @theme, file)
      unless File.exist?(theme_file)
        theme_file = File.join(File.dirname(__FILE__), "..", "..", "themes", "default", file)
      end
      fail "StandardError", "#{theme_file} not found." unless File.exist?(theme_file)
      File.read(theme_file)
    end

    def style
      load_theme_file("sequence_style.css")
    end
  end
end
