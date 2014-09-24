#!/usr/bin/env ruby
#
# This script takes an SVG that has embedded <image> tags  that reference SVG
# files and replaces them with the SVG content instead. This results in a file
# that displays correctly in a chrome <img> tag and has no external references.
require 'nokogiri'

infile = ARGV[0] || fail(ArgumentError, "Missing input file")

asset_path = File.join(File.dirname(__FILE__), "..", "assets", "images")

sample = Nokogiri::XML(File.read(infile))

sample.css('image').each do |image|
  image_file = File.join(asset_path, image.attr("xlink:href"))

  unless File.extname(image_file) == ".svg"
    puts "#{image_file} is not an SVG file"
    next
  end

  unless File.exist?(image_file)
    puts "Couldn't find #{image_file}. Skipping."
    next
  end

  x = image.attr("x")
  y = image.attr("y")
  width = image.attr("width")
  height = image.attr("height")

  # TODO: cache these for reuse
  symbol = Nokogiri::XML(File.read(image_file)).at_css("svg")

  symbol_attrs = symbol.attributes
  view_box = nil
  if symbol_attrs.include?("viewBox")
    view_box = symbol.attr("viewBox")
  elsif symbol_attrs.include?("width") && symbol_attrs.include?("height")
    view_box = "0 0 #{symbol.attr("width")} #{symbol.attr("height")}"
  end
  symbol.set_attribute("x", x)
  symbol.set_attribute("y", y)
  symbol.set_attribute("width", width)
  symbol.set_attribute("height", height)
  symbol.set_attribute("viewBox", view_box) if view_box

  image.replace(symbol)
end

outfile = "#{File.basename(infile, ".svg")}.fixed.svg"

File.open(outfile, "w") { |f| f.write(sample.to_xml) }
