module Umlit
  class SequenceDiagram
    def self.create(infile, outfile = nil)
      sequence_parser = Umlit::SequenceParser.new
      sequence = sequence_parser.parse(infile)

      renderer = Umlit::SequenceRenderer.new

      renderer.rowy = sequence_parser.rowy

      outfile = "#{File.basename(infile, ".wsd")}.svg" if outfile.nil?
      File.open(outfile, "w") do |f|
        f.write(renderer.render(sequence))
      end
    end
  end
end
