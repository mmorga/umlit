#!/usr/bin/env ruby
#
# This script takes an SVG that has embedded <image> tags  that reference SVG
# files and replaces them with the SVG content instead. This results in a file
# that displays correctly in a chrome <img> tag and has no external references.
#
# Two approaches are possible:
#
# 1. Paste the referenced image into the svg.
# 2. Insert a symbol into the image and reference it where needed.
#    a. Figure out a mapping from file name to id
#    b. When seeing a reference to a previous file, just add use tag referencing the id
#    c. When no previous element, insert a symbol element with the computed viewBox and id

require 'nokogiri'

class SvgImageFixer
  attr_reader :file_to_id_hash, :infile, :outfile, :asset_path

  def self.fix(infile)
    svg_image_fixer = SvgImageFixer.new(infile)
    svg_image_fixer.fix
  end

  def initialize(infile, outfile = nil)
    @infile = infile
    @outfile = outfile || "#{File.basename(infile, ".svg")}.fixed.svg"
    @file_to_id_hash = {}
    @asset_path = File.join(File.dirname(__FILE__), "..", "assets", "images")
  end

  def fix
    svg = Nokogiri::XML(File.read(infile))

    svg.css('image').each do |image|
      replace_image(image)
    end

    File.open(outfile, "w") { |f| f.write(svg.to_xml) }
  end

  def unsupported_case(image_file)
    unless File.extname(image_file) == ".svg"
      puts "#{image_file} is not an SVG file"
      return true
    end

    unless File.exist?(image_file)
      puts "Couldn't find #{image_file}. Skipping."
      return true
    end
    false
  end

  def view_box_for(symbol)
    symbol_attrs = symbol.attributes
    view_box = nil
    if symbol_attrs.include?("viewBox")
      view_box = symbol.symbol_attrs["viewBox"]
    elsif symbol_attrs.include?("width") && symbol_attrs.include?("height")
      view_box = "0 0 #{symbol_attrs["width"]} #{symbol_attrs["height"]}"
    end
    view_box
  end

  def replace_image(image)
    image_file = File.join(asset_path, image.attr("xlink:href"))

    return if unsupported_case(image_file)

    x = image.attr("x")
    y = image.attr("y")
    width = image.attr("width")
    height = image.attr("height")

    # TODO: cache these for reuse
    symbol = Nokogiri::XML(File.read(image_file)).at_css("svg")

    view_box = view_box_for(symbol)

    symbol.set_attribute("x", x)
    symbol.set_attribute("y", y)
    symbol.set_attribute("width", width)
    symbol.set_attribute("height", height)
    symbol.set_attribute("viewBox", view_box) if view_box
    # TODO: what would the appropriate preserveAspectRatio attribute value

    image.replace(symbol)
  end
end

infile = ARGV[0] || fail(ArgumentError, "Missing input file")

SvgImageFixer.fix(infile)
