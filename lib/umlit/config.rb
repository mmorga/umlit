module Umlit
  class Config
    attr_reader :verbose, :input_file, :output_directory, :output_file

    DEFAULTS = {
      "verbose" => false,
      "output_directory" => ".",
    }

    def initialize(cfg)
      @cfg_hash = DEFAULTS.merge(cfg.to_h)
      @verbose = @cfg_hash["verbose"]
      @input_file = @cfg_hash["input_file"]
      @output_directory = @cfg_hash["output_directory"] ||
        File.dirname(@input_file)
      @output_file = @cfg_hash["output_file"] ||
        File.join(@output_directory, File.basename(@input_file.ext(".svg")))
    end

    def to_h
      @cfg_hash.dup
    end
  end
end
