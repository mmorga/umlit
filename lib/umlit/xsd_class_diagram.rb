require "nokogiri"

module Umlit
  class XsdClassDiagram
    def self.create(infile)
      xsd = Nokogiri::XML(File.read(infile))
      schema_name = File.basename(infile, ".xsd")
      outfile = "#{schema_name}.dot"
      File.open(outfile, "w") do |f|
        f.write("digraph #{schema_name} {\n")
        f.write("  splines=\"ortho\"\n")
        f.write("  node[shape=\"plain\",fontname=\"Helvetica\"];")
        f.write("  edge[fontname=\"Helvetica\"];")

        xsd.css('xs|schema > xs|element').each do |e|
          name = e.attr("name")
          type = e.attr("type").sub(/.+:/, '') # Rip off namespace

          label = "<table cellspacing=\"0\" cellborder=\"0\"><tr><td><font point-size=\"10\">&lt;&lt;element&gt;&gt;</font><br/><font face=\"Helvetica-Bold\">#{name}</font></td></tr></table>"
          f.write("  #{name} [label=<#{label}>];\n")
          f.write("  #{name} -> #{type} [arrowhead=\"onormal\"];\n")
        end

        xsd.css('xs|schema > xs|complexType').each do |c|
          name = c.attr("name")
          label = "<table cellspacing=\"0\" cellborder=\"0\">"
          label << "<tr><td><font point-size=\"10\">&lt;&lt;complexType&gt;&gt;</font><br/><font face=\"Helvetica-Bold\">#{name}</font></td></tr>"
          label << "<hr/>" unless c.css('xs|attribute').empty?
          compositions = []
          c.css('xs|attribute').each do |a|
            attr_name = a.attr("name")
            attr_type = a.attr("type").sub(/.+:/, '')
            compositions << a unless attr_type.nil?
            label << "<tr><td align=\"left\"><font color=\"#a35d00\">#{attr_name}: #{attr_type}</font></td></tr>"
          end
          label << "<hr/>" unless c.css('xs|sequence').empty?
          c.css('xs|sequence').children.each do |a|
            next if a.instance_of?(Nokogiri::XML::Text)
            if a.name == "choice"
              a.children.each do |cc|
                next if cc.instance_of?(Nokogiri::XML::Text)
                a_name = cc.attr("name") || cc.attr("ref")
                a_type = cc.attr("type") || cc.attr("ref")
                a_type = a_type.sub(/.+:/, '') unless a_type.nil?
                compositions << cc unless a_type.nil?
                label << "<tr><td align=\"left\"><font face=\"Helvetica-Bold\">Choice: </font><font color=\"#057c20\">#{a_name}: #{a_type}</font></td></tr>"
              end
            else
              a_name = a.attr("name") || a.attr("ref")
              a_type = a.attr("type") || a.attr("ref")
              a_type = a_type.sub(/.+:/, '') unless a_type.nil?
              compositions << a unless a_type.nil?
              label << "<tr><td align=\"left\"><font color=\"#057c20\">#{a_name}: #{a_type}</font></td></tr>"
            end
          end
          label << "</table>"
          f.write("  #{name} [label=<#{label}>];\n")

          compositions.each do |el|
            comp = el.attr("type") || el.attr("ref")
            comp = comp.sub(/.+:/, '') unless comp.nil?
            next if %w(string link date boolean integer int).include?(comp)
            puts el.inspect if comp.nil? || comp == ''
            min_occurs = el.attr("minOccurs") || "1"
            max_occurs = el.attr("maxOccurs") || "1"
            if min_occurs == max_occurs
              edge_label = "#{min_occurs}"
            else
              max_occurs = "*" if max_occurs == "unbounded"
              edge_label = "#{min_occurs}..#{max_occurs}"
            end
            f.write("  #{comp} -> #{name} [arrowhead=\"diamond\",taillabel=\"#{edge_label}\"];\n")
          end
        end

        xsd.css('xs|schema > xs|simpleType').each do |s|
          name = s.attr("name")
          label = "<table cellspacing=\"0\" cellborder=\"0\">"
          label << "<tr><td><font point-size=\"10\">&lt;&lt;simpleType&gt;&gt;</font><br/><font face=\"Helvetica-Bold\">#{name}</font></td></tr>"
          label << "<hr/>" unless s.css('xs|enumeration').empty?
          s.css('xs|enumeration').each do |enum|
            label << "<tr><td>&quot;<font color=\"#181da3\">#{enum.attr("value")}</font>&quot;</td></tr>"
          end
          label << "</table>"
          f.write("  #{name} [label=<#{label}>];\n")
          next if s.css('xs|union').empty?
          s.css('xs|union').attr("memberTypes").value.split(" ").map { |ut| ut.sub(/.+:/, '') }.each do |union_type|
            next if %w(string link date boolean integer int).include?(union_type)
            f.write("  #{union_type} -> #{name} [arrowhead=\"diamond\",taillabel=\"1\"];\n")
          end
        end

        f.write("}\n")
      end
    end
  end
end
