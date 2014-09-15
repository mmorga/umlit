# 8.5x11in

# 765x990px
# 612x792pt

# 0.8 px = 1 pt

# converting funits to pixels

# pointSize * resolution / (72 * units_per_em)

# 16px = 12pt (guideline)

# 16px Tahoma "A" is 9.75w x 11.633h

# Tahoma units_per_em = 2048

# A width = 1238 - (-10) = 1248

# 9.75 = 1248 * resolution * 16 / 2048 * 72

# 9.75 = 19968 * resolution / 147456

# 9.75 = 0.135416666666667 * resolution
# resolution = 72

# So glyph width size = glyph_width * font_size_px / units_per_em

# 1489 / 2048 * 16 = 11.633

def string_size(font, string, size)
  # TODO: find the font in the font path
  font = TTFunk::File.open("/Library/Fonts/Tahoma.ttf")

  # font.cmap.unicode.first["A".unpack("U*").first] #=> 36
  font_codes = string.unpack("U*").map { |c| font.cmap.unicode.first[c] }
  width = 0
  height = 0
  font_codes.each_with_index do|c, i|
    glyph = font.glyph_outlines.for(c)
    width += glyph.x_max - glyph.x_min
    h = glyph.y_max - glyph.y_min
    height = h if h > height
    # [glyph.x_min, glyph.y_min, glyph.x_max, glyph.y_max] #=> [-10, 0, 1238, 1489]
    units_per_em = font.header.units_per_em
    if i > 0
      if font.kerning.tables.first.pairs.include?([font_codes[i - 1], c])
        width -= font.kerning.tables.first.pairs[[font_codes[i - 1], c]]
      end
    end
  end
  [scale(width, size, units_per_em), scale(height, size, units_per_em)]
end

def scale(val, factor, units_per_em)
  val * factor / units_per_em
end
