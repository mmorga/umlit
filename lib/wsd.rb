#!/usr/bin/env ruby -wU

require 'RMagick'

def text_size(text, font_size = 10, font_weight = Magick::NormalWeight,
              font = "/System/Library/Fonts/Helvetica.dfont",
              font_style = Magick::NormalStyle)
  label = Magick::Draw.new
  label.font = font
  label.text_antialias(true)
  label.pointsize = font_size
  label.font_style = font_style
  label.font_weight = font_weight
  label.gravity = Magick::CenterGravity
  # label.density = "96x96"
  label.text(0, 0, text)
  label.get_type_metrics(text)
end

def process_file(infile)
  outfile = "#{File.basename(infile, ".wsd")}.svg"

  title = ""
  rows = []
  actors = []
  interactions = []
  activations = {}
  depth = 0
  notes = []
  rowy = 75
  in_note = false
  f = IO.foreach(infile) do|line|
    if  /title (.+)/ =~ line
      title = Regexp.last_match[1]
      # rowy += 15
    elsif /([a-zA-Z0-9]+)(\-?-\>)(.+)\:(.+)/ =~ line
      lnode = Regexp.last_match[1].strip
      style = Regexp.last_match[2]
      rnode = Regexp.last_match[3].strip
      msg = Regexp.last_match[4].strip
      rows << { lnode: lnode, rnode: rnode, message: msg, top: rowy, style: style == "-->" ? "dashed" : "solid" }
      actors << lnode unless actors.include?(lnode)
      actors << rnode unless actors.include?(rnode)
      rowy += 40
    elsif /(alt|opt|loop) (.+)/ =~ line
      interactions << {
        type: Regexp.last_match[1].strip,
        message: Regexp.last_match[2].strip,
        start: rowy,
        elses: [],
        depth: depth }
      depth += 1
      rowy += 20
    elsif /else (.+)/ =~ line
      interactions.last[:elses] << { row: rowy, message: Regexp.last_match[1].strip }
      rowy += 20
    elsif line.strip == 'end'
      last = interactions.size - 1
      last -= 1 while interactions[last].key?(:end)
      interactions[last][:end] = rowy
      rowy += 15
      depth -= 1
    elsif /deactivate (.+)/ =~ line
      node = Regexp.last_match[1].strip
      activations[node].last[:end] = rowy - 30
    elsif /activate (.+)/ =~ line
      node = Regexp.last_match[1].strip
      activations[node] = [] unless activations.key?(node)
      activations[node] << { start: rowy - 30 }
    elsif /note (over|left of|right of) ([a-zA-Z0-9,]+)(\:(.+))?/ =~ line
      note_nodes = Regexp.last_match[2].strip.split(",")
      notes << {
        start: rowy,
        end: rowy + 20,
        left: note_nodes.first.strip,
        right: note_nodes.last.strip,
        messages: Regexp.last_match[4].nil? ? [] : [Regexp.last_match[4].strip],
        position: Regexp.last_match[1].strip
      }
      if !Regexp.last_match[4].nil?
        rowy += 25
      else
        in_note = true
      end
    elsif /end note/ =~ line
      notes.last[:end] = rowy + 5
      rowy += 10
      in_note = false
    elsif /^ +(.+)/ =~ line
      # multiline note or side diagram text
      # notes.last[:message] = "" unless notes.last.has_key?(:message)
      if in_note
        notes.last[:messages] << Regexp.last_match[1]
      else
        # do something
      end
      rowy += 10
    end

    # puts line
  end
  ############################
  # Calculate Sizes
  ############################

  # Calculate Positions based on Actor width
  actor_height = 36
  actor_widths = []
  actor_mid_points = []
  actor_spacing = []
  actors.each_with_index do |node, idx|
    metrics = text_size(node, 10, Magick::BoldWeight)
    actor_widths << (metrics.width + metrics.max_advance * 3)
    mid_point = actor_widths[idx] / 2
    x = mid_point
    x = x + actor_mid_points[idx - 1] + 20 + (actor_widths[idx - 1] / 2) if idx > 0
    actor_mid_points << x
    actor_spacing[idx] ||= 0
    actor_spacing[idx] = actor_spacing[idx] + mid_point
    actor_spacing[idx + 1] = mid_point + 10
    # puts "Initial actor spacing #{actor_spacing[idx].inspect}"
  end

  # Adjust spacing based on Message width
  rows.each do |row|
    metrics = text_size(row[:message])
    x1 = actor_mid_points[actors.index(row[:lnode])]
    x2 = actor_mid_points[actors.index(row[:rnode])]
    next if (x2 - x1).abs >= (metrics.width + metrics.max_advance * 3)

    # puts "Message is too long row #{row[:message]} between #{row[:lnode]} and #{row[:rnode]}"
    l_idx, r_idx = [actors.index(row[:lnode]), actors.index(row[:rnode])].sort
    steps = (l_idx - r_idx).abs
    steps = 1 if steps == 0
    new_width = (metrics.width) / steps + metrics.max_advance * 3
    # puts "Setting for message '#{row[:message]}' (width: #{metrics.width}) spacing between #{row[:lnode]} and #{row[:rnode]} to #{new_width}"
    (l_idx..r_idx).each { |i| actor_spacing[i + 1] = new_width if actor_spacing[i + 1] < new_width }
  end

  actor_mid_points.each_with_index do |_mp, i|
    actor_mid_points[i] = actor_spacing[i]
    actor_mid_points[i] = actor_mid_points[i] + actor_mid_points[i - 1] if i > 0
    # puts actor_mid_points[i]
  end

  diagram_width = actor_mid_points.last + actor_spacing.last
  diagram_height = rowy + 55

  ############################
  # Render
  ############################
  f = File.new(outfile, "w")

  f.write <<-SVG
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
 "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="#{diagram_width}pt" height="#{diagram_height}pt"
 viewBox="0 0 #{diagram_width} #{diagram_height}" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <defs>
    <style>
      text {
        font-family: Helvetica;
        font-size: 10pt;
      }
      .participant {
        font-weight: bold;
      }
      .group {
        font-weight: bold;
      }
      rect {
        fill: #fff;
      }
      rect,line,path {
        stroke: #000;
        stroke-width: 1;
      }
      path,line {
        fill: none;
      }
      .signal {
        marker-end: url(#FilledArrow_Marker);
      }
      .reply {
        marker-end: url(#OpenArrow_Marker);
      }
      .group-box {
        stroke: #008;
        fill: none;
        stroke-width: 2;
      }
      .activation-box {
        fill: #fff;
      }
      .group-box-title {
        stroke: #008;
        fill: #fff;
      }
      .note-box {
        stroke: #800;
        fill: #fff;
      }
      .note {
        font-color: #400;
      }
      .ruler {
        stroke: red;
      }
      .spacing {
        stroke: green;
      }
    </style>
    <marker
       orient="auto"
       id="FilledArrow_Marker"
       style="color:#000;overflow:visible"
       refX="0"
       refY="0">
       <path
          d="M 10.0,0.0 L 10.0,-12.0 L -20,0.0 L 10.0,12.0 L 10.0,0.0 z"
           id="solid-arrow-head"
           style="fill-rule:evenodd;fill:currentColor;stroke:none;stroke-width:1;stroke-dasharray:none;"
           transform="scale(0.5) rotate(180) translate(20,0)" />
    </marker>
    <marker
       orient="auto"
       id="OpenArrow_Marker"
       style="color:#000;overflow:visible"
       refX="0"
       refY="0">
       <path
          d="M 10.0,-12.0 L -20,0.0 L 10.0,12.0"
           id="open-arrow-head"
           style="stroke:currentColor;stroke-width:1;stroke-dasharray:none;"
           transform="scale(0.5) rotate(180) translate(20,0)" />
    </marker>
  </defs>
SVG
  f.write("<title>#{title}</title>\n")

  # Draw in the participant interactions and vertical lines
  mid_height = actor_height / 2
  actors.each_with_index do |node, idx|
    mid_point = actor_widths[idx] / 2
    x = actor_mid_points[idx]
    f.write("<rect x='#{x - mid_point}' y='0' width='#{actor_widths[idx]}' height='#{actor_height}' class='participant-box'/>\n")
    f.write("<text textLength='#{text_size(node, 12, Magick::BoldWeight).width}' font-size='10' font-family='Helvetica' font-weight='bold' x='#{x}' y='#{mid_height}' text-anchor='middle' class='participant'>#{node}</text>\n")
    f.write("<line x1='#{x}' y1='#{actor_height}' x2='#{x}' y2='#{rowy}' class='participant-line'/>\n")
  end

  # Draw messages
  rows.each do |row|
    y = row[:top]
    x1 = actor_mid_points[actors.index(row[:lnode])]
    x2 = actor_mid_points[actors.index(row[:rnode])]
    f.write("<text textLength='#{text_size(row[:message], 12).width}' font-size='10' font-family='Helvetica' x='#{(x1 < x2 ? x1 : x2) + 5}' y='#{y}' class='message'>#{row[:message]}</text>\n")
    if row[:style] == "dashed"
      style = ' stroke-dasharray="4,4"'
      path_class = "reply"
    else
      style = ''
      path_class = "signal"
    end
    y += 10
    if row[:lnode] == row[:rnode]
      f.write("<path d='M #{x1},#{y} l 50.0,0 l 0.0,15 l -50.0,0.0' class='#{path_class}' #{style}/>\n")
    else
      f.write("<line x1='#{x1}' y1='#{y}' x2='#{x2}' y2='#{y}' class='#{path_class}' #{style}/>\n")
    end
  end

  # Draw Activations
  activations.each do |node, acts|
    x = actor_mid_points[actors.index(node)] - 5
    acts.each do|act|
      y = act[:start]
      width = 10
      height = (act[:end] - act[:start])
      f.write("<rect x='#{x}' y='#{y}' width='#{width}' height='#{height}' class='activation-box'/>\n")
    end
  end

  # Draw group interactions
  interactions.each do |box|
    x1 = box[:depth] * 10
    width = diagram_width - (box[:depth] * 20)
    y1 = box[:start]
    height = box[:end] - box[:start]
    f.write("<rect x='#{x1}' y='#{y1}' width='#{width}' height='#{height}' class='group-box'/>\n")
    f.write("<path d='M #{x1}, #{y1 + 15} l 25.0,0 l 5.0,-5.0 l 0.0,-10.0 l -30.0,0 z' class='group-box-title'/>\n")
    f.write("<text x='#{x1 + 5}' y='#{y1 + 12}' class='group'>#{box[:type]}</text>\n")
    f.write("<text x='#{x1 + 40}' y='#{y1 + 12}' class='group'>[#{box[:message]}]</text>\n")
    box[:elses].each do|else_item|
      ey = else_item[:row]
      f.write("<line x1='#{x1}' y1='#{ey}' x2='#{width}' y2='#{ey}' stroke-dasharray='4,4'/>\n")
      f.write("<text x='#{x1 + 40}' y='#{ey + 10}' class='group'>[#{else_item[:message]}]</text>\n")
    end
  end

  # Draw Notes
  notes.each do |note|
    # :start, :end, :left (node name), :right (node name), :message, :position (over, left of or right of)
    leftidx, rightidx = [actors.index(note[:left]), actors.index(note[:right])].sort

    if note[:position] == 'over'
      x = actor_mid_points[leftidx] - actor_spacing[leftidx] / 2
      width = actor_mid_points[rightidx] + (actor_spacing[rightidx + 1] / 2) - x
    elsif note[:position] == 'right of'
      x = actor_mid_points[rightidx] + 15
      width = actor_spacing[rightidx + 1] - 30
    elsif note[:position] == 'left of'
      x = actor_mid_points[leftidx] - actor_spacing[leftidx] + 15
      width = actor_spacing[leftidx] - 30
    end
    y1 = note[:start]
    y2 = note[:end]

    width = 90 if width <= 50 # TODO
    f.write("<path d='M #{x},#{y1} l #{width - 5},0 l 5,5 l -5,0 l 0,-5, l 5,5 l 0,#{y2 - y1 - 5} l #{-width},0 z' class='note-box'/>\n")
    y1 += 3
    note[:messages].each do|message|
      y1 += 10
      f.write("<text x='#{x + 5}' y='#{y1}' class='note'>#{message}</text>\n")
    end
  end

  f.write("</svg>")
  f.close
end

fail StandardError, "Missing Filename" if ARGV.empty?

ARGV.each do |file|
  process_file(file)
end
