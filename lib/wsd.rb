#!/usr/bin/env ruby -wU

# Copy of web sequence diagrams for local use

title = ""
rows = []
# nodes = {}
node_order = []
boxes = []
activations = {}
depth = 0
notes = []
rowy = 75
in_note = false
f = IO.foreach("sample.wsd") do|line|
  if  /title (.+)/ =~ line
    title = Regexp.last_match[1]
    # rowy += 15
  elsif /([a-zA-Z0-9]+)(\-?-\>)(.+)\:(.+)/ =~ line
    lnode = Regexp.last_match[1].strip
    style = Regexp.last_match[2]
    rnode = Regexp.last_match[3].strip
    msg = Regexp.last_match[4].strip
    rows << { lnode: lnode, rnode: rnode, message: msg, top: rowy, style: style == "-->" ? "dashed" : "solid" }
    node_order << lnode unless node_order.include?(lnode)
    node_order << rnode unless node_order.include?(rnode)
    rowy += 40
  elsif /(alt|opt|loop) (.+)/ =~ line
    boxes << {
      type: Regexp.last_match[1].strip,
      message: Regexp.last_match[2].strip,
      start: rowy,
      elses: [],
      depth: depth }
    depth += 1
    rowy += 20
  elsif /else (.+)/ =~ line
    boxes.last[:elses] << { row: rowy, message: Regexp.last_match[1].strip }
    rowy += 20
  elsif line.strip == 'end'
    last = boxes.size - 1
    last -= 1 while boxes[last].key?(:end)
    boxes[last][:end] = rowy
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

  puts line
end

f = File.new("sample.svg", "w")
width = (node_order.size + 1) * 100
height = rowy + 55

f.write <<-SVG
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
 "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="#{width}pt" height="#{height}pt"
 viewBox="0 0 #{width} #{height}" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <defs>
    <style>
      svg {
        font: Georgia;
        font-size: 8pt;
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
      .participant {
        font-size: 10pt;
        font-weight: bold;
      }
      .message {
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
      .group {
        font-weight: bold;
      }
      .note-box {
        stroke: #800;
        fill: #fff;
      }
      .note {
        font-color: #400;
      }
    </style>
    <marker
       orient="auto"
       id="FilledArrow_Marker"
       style="color:#000;overflow:visible"
       refX="0"
       refY="0">
       <path
          d="M 5.0,0.0 L 5.0,-8.0 L -15.5,0.0 L 5.0,8.0 L 5.0,0.0 z"
           id="path4953"
           style="fill-rule:evenodd;fill:currentColor;stroke:none;stroke-width:1;stroke-dasharray:none;"
           transform="scale(0.4) rotate(180) translate(10,0)" />
    </marker>
  </defs>
SVG
f.write("<title>#{title}</title>\n")

# Draw in the participant boxes and vertical lines
node_order.each_with_index do|node, idx|
  x = idx * 100
  f.write("<rect x='#{x}' y='0' width='50' height='50' class='participant-box'/>\n")
  f.write("<text x='#{x + 25}' y='25' text-anchor='middle' class='participant'>#{node}</text>\n")
  f.write("<rect x='#{x}' y='#{rowy}' width='50' height='50' class='participant-box'/>\n")
  f.write("<text x='#{x + 25}' y='#{rowy + 25}' text-anchor='middle' class='participant'>#{node}</text>\n")
  f.write("<line x1='#{x + 25}' y1='50' x2='#{x + 25}' y2='#{rowy}' class='participant-line'/>\n")
end

# Draw group boxes
boxes.each do|box|
  x1 = box[:depth] * 10
  width = node_order.size * 100 - (box[:depth] * 20)
  y1 = box[:start]
  height = box[:end] - box[:start]
  f.write("<rect x='#{x1}' y='#{y1}' width='#{width}' height='#{height}' class='group-box'/>\n")
  f.write("<path d='M #{x1}, #{y1 + 15} l 25.0,0 l 5.0,-5.0 l 0.0,-10.0 l -30.0,0 z' class='group-box-title'/>\n")
  f.write("<text x='#{x1 + 5}' y='#{y1 + 10}' class='group'>#{box[:type]}</text>\n")
  f.write("<text x='#{x1 + 40}' y='#{y1 + 10}' class='group'>[#{box[:message]}]</text>\n")
  box[:elses].each do|else_item|
    ey = else_item[:row]
    f.write("<line x1='#{x1}' y1='#{ey}' x2='#{width}' y2='#{ey}' stroke-dasharray='4,4'/>\n")
    f.write("<text x='#{x1 + 40}' y='#{ey + 10}' class='group'>[#{else_item[:message]}]</text>\n")
  end
end

# Draw Activations
activations.each do|node, acts|
  x = node_order.index(node) * 100 + 20
  acts.each do|act|
    y = act[:start]
    width = 10
    height = (act[:end] - act[:start])
    f.write("<rect x='#{x}' y='#{y}' width='#{width}' height='#{height}' class='activation-box'/>\n")
  end
end

# Draw Notes
notes.each do|note|
  # :start, :end, :left (node name), :right (node name), :message, :position (over, left of or right of)
  leftidx = node_order.index(note[:left])
  rightidx = node_order.index(note[:right])
  if note[:position] == 'over'
    x = (leftidx + ((rightidx - leftidx) / 2.0)) * 100 - 50
  elsif note[:position] == 'right of'
    x = rightidx * 100 + 30
  elsif note[:position] == 'left of'
    x = leftidx * 100 - 70
  end
  y1 = note[:start]
  y2 = note[:end]

  width = (rightidx - leftidx) * 100 + 50
  width = 90 if width <= 50
  f.write("<path d='M #{x},#{y1} l #{width - 5},0 l 5,5 l -5,0 l 0,-5, l 5,5 l 0,#{y2 - y1 - 5} l #{-width},0 z' class='note-box'/>\n")
  y1 += 3
  note[:messages].each do|message|
    y1 += 10
    f.write("<text x='#{x + 5}' y='#{y1}' class='note'>#{message}</text>\n")
  end
end
# Draw messages
rows.each_with_index do|row, _idx|
  y = row[:top]
  x1 = 25 + (node_order.index(row[:lnode]) * 100)
  x2 = 25 + (node_order.index(row[:rnode]) * 100)
  f.write("<text x='#{(x1 < x2 ? x1 : x2) + 10}' y='#{y}' class='message'>#{row[:message]}</text>\n")
  if row[:style] == "dashed"
    style = ' stroke-dasharray="4,4"'
  else
    style = ''
  end
  y += 10
  if row[:lnode] == row[:rnode]
    f.write("<path d='M #{x1},#{y} l 50.0,0 l 0.0,15 l -50.0,0.0' class='signal' #{style}/>\n")
  else
    f.write("<line x1='#{x1}' y1='#{y}' x2='#{x2}' y2='#{y}' class='signal' #{style}/>\n")
  end
end
f.write("</svg>")
f.close
