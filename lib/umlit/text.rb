require 'RMagick'

module Umlit
  class Text
    attr_reader :options

    OPTION_DEFAULTS = {
      font: "/System/Library/Fonts/Helvetica.dfont", # TODO: search for this
      text_antialias: true,
      pointsize: 12,
      font_style: Magick::NormalStyle,
      font_weight: Magick::NormalWeight,
      gravity: Magick::CenterGravity
    }

    def initialize(options = {})
      @options = OPTION_DEFAULTS.merge(options)
    end

    def metrics(text, options = {})
      opts = @options.merge(options)
      label = Magick::Draw.new
      opts.each do |attr, val|
        label.send("#{attr}=", val)
      end
      label.text(0, 0, text)
      label.get_type_metrics(text)
    end

    def width(text, options = {})
      metrics(text, options).width
    end

    def height(text, options = {})
      metrics(text, options).height
    end
  end
end
