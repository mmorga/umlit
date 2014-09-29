require 'nokogiri'
require 'ostruct'

module Umlit
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
  #
  # Option 2 is more efficient since each referenced SVG is only included in the
  # parent once so that's what we do.
  class FixSvgDiagram
    attr_reader :file_to_id_hash, :infile, :outfile, :asset_path, :svg

    def self.create(infile, outfile = nil)
      fix_svg_diagram = FixSvgDiagram.new(infile, outfile)
      fix_svg_diagram.fix
    end

    def initialize(infile, outfile = nil)
      @infile = infile
      @outfile = outfile || "#{File.basename(infile, ".svg")}.fixed.svg"
      @file_to_id_hash = {}
      @asset_path = File.join(File.dirname(__FILE__), "..", "..", "assets", "images")
    end

    def fix
      @svg = Nokogiri::XML(File.read(infile))

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

    # Formats an id based on the image file name ensuring it is unique in the SVG
    def id_for_image_file(image_file)
      sym_id = File.basename(image_file, ".svg").gsub(/[\s_]/, "-").downcase
      sym_id << "-symbol"
      until svg.css("[id=\"#{sym_id}\"]").empty?
        d = 1
        sym_id.match(/(\d+)$/) { |md| d = md[1].to_i }
        d += 1
        sym_id.sub(/(\d+)$/, d.to_s)
      end
      sym_id
    end

    def insert_symbol(image_file, symbol_id)
      defs = svg.at_css("svg>defs")
      if defs.nil?
        defs = Nokogiri::XML::Node.new "defs", svg
        svg.at_css("svg").add_child(defs)
      end
      symbol_svg = Nokogiri::XML(File.read(image_file)).at_css("svg")
      view_box = view_box_for(symbol_svg)
      # TODO: what would the appropriate preserveAspectRatio attribute value

      symbol = Nokogiri::XML::Node.new "symbol", svg
      symbol.set_attribute("id", symbol_id)
      symbol.set_attribute("viewBox", view_box) if view_box
      symbol.add_child(symbol_svg)
      defs.add_child(symbol)
    end

    def symbol_for_filename(image_file)
      return file_to_id_hash[image_file] if file_to_id_hash.include?(image_file)

      symbol_id = id_for_image_file(image_file)
      file_to_id_hash[image_file] = symbol_id

      insert_symbol(image_file, symbol_id)
      symbol_id
    end

    def replace_image(image)
      image_file = image.attr("xlink:href")
      image_file = File.join(asset_path, File.basename(image_file)) unless File.exist?(image_file)

      return if unsupported_case(image_file)

      ia = OpenStruct.new(image.attributes)

      symbol_id = symbol_for_filename(image_file)

      use = Nokogiri::XML::Node.new "use", svg
      use.set_attribute("x", ia.x)
      use.set_attribute("y", ia.y)
      use.set_attribute("width", ia.width)
      use.set_attribute("height", ia.height)
      use.set_attribute("xlink:href", "##{symbol_id}")

      image.replace(use)
    end
  end
end
