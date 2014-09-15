#!/usr/bin/env ruby -wU
#
# Refactoring Plan
#
# * Turn various global variables into a class or struct
# * Complete separation of size/position calc from SVG render
# * Make a better parser - maybe an inside DSL for Ruby or a complete clean outside DSL
# * Eliminate dependency on RMagick
# * Allow style customization
# * Add groups where appropriate in SVG render for a nicer diagram to manipulate in inkscape
# * Create a javascript tool to permit navigating through large diagrams
# * Look into a way to overlay actor headings when zoomed in or scrolled down

require_relative "./text"
require_relative "./sequence"
require_relative "./sequence_renderer"
require_relative "./sequence_parser"

def process_file(infile)
  sequence_parser = Umlit::SequenceParser.new(rowy: 75)
  sequence = sequence_parser.parse(infile)

  renderer = Umlit::SequenceRenderer.new

  renderer.rowy = sequence_parser.rowy

  File.open("#{File.basename(infile, ".wsd")}.svg", "w") do |f|
    f.write(renderer.render(sequence))
  end
end

fail StandardError, "Missing Filename" if ARGV.empty?

ARGV.each do |file|
  process_file(file)
end
