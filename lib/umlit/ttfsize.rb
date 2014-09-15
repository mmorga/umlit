require 'ttfunk'

# based on TTF_SizeUNICODE on sdl_ttf
def textSize(font, text)
  text.each do|c|
    character_code = c.unpack("U*").first
    glyph_id = font.cmap.unicode.first[character_code]
    glyph = font.glyph_outlines.for(glyph_id)
    bbox = [glyph.x_min, glyph.y_min, glyph.x_max, glyph.y_max]
  end
end
