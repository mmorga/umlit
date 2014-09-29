require 'graphviz'
require 'tempfile'

module Umlit
  class GraphvizDiagram
    attr_reader :infile, :outfile, :asset_path, :dot_file, :asset_names

    def self.create(infile, outfile = nil)
      graphviz_diagram = GraphvizDiagram.new(infile, outfile)
    end

    def initialize(infile, outfile)
      @outfile = "#{File.basename(infile, ".dot")}.svg" if outfile.nil?

      # Read the dot file
      @dot_file = File.read(infile)

      # replace references to images to reference asset path
      @asset_path = File.join(File.dirname(__FILE__), "..", "..", "assets", "images")
      @asset_names = Dir.glob(File.join(asset_path, "*.svg")).map { |f| File.basename(f) }

      @asset_names.each do |asset|
        dot_file.gsub!(/image\s*=\s*["']#{asset}["']/, "image=\"#{File.join(asset_path, asset)}\"")
      end
      puts dot_file
      temp_dot = Tempfile.new("processed-dot")
      begin
        temp_dot.write(dot_file)
        temp_dot.close
        puts "Running Graphviz"
        GraphViz.parse(temp_dot.path, path: "/usr/local/bin").output(svg: outfile)
        puts " - Done Running Graphviz"
      ensure
        temp_dot.unlink
      end
      puts "Fix Svg Diagram"
      FixSvgDiagram.create(outfile, outfile)
      puts " - Done Fix Svg Diagram"
    end
  end
end
