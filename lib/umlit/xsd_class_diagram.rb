require "nokogiri"

# TODO: handle annotations
# TODO: handle namespaces - option to put namespaces in a cluster
# TODO: Add an option to export only the items related to a single element or type
# TODO: handle schema includes
# TODO: handle schema imports
module Umlit
  class XsdClassDiagram
    def self.create(infile)
      xsd_class_diagram = new
      xsd_class_diagram.draw(infile)
    end

    def graph_settings
      node = MustacheViews::Node.new("graph", "splines" => "ortho")
      node
    end

    def node_settings
      node = MustacheViews::Node.new("node", "shape" => "plain", "fontname" => "Helvetica")
      node
    end

    def edge_settings
      node = MustacheViews::Node.new("edge", "fontname" => "Helvetica")
      node
    end

    def create_graph(name)
      graph = MustacheViews::Graph.new(name)
      graph.nodes << graph_settings
      graph.nodes << node_settings
      graph.nodes << edge_settings
      graph
    end

    def without_namespace(str)
      return nil if str.nil?
      str.sub(/.+:/, '')
    end

    def add_element(node, graph)
      name = node.attr("name")
      type = without_namespace(node.attr("type"))
      label = MustacheViews::ClassLabel.new(name, node.name).render
      graph.nodes << MustacheViews::Node.new(name, "label" => label)
      graph.nodes << MustacheViews::EdgeNode.new(name, type, "arrowhead" => "onormal")
      graph
    end

    # TODO: refactor this big mess
    def add_complex_type(node, graph)
      name = node.attr("name")
      # type = without_namespace(node.attr("type"))
      compositions = []
      attributes = {}
      methods = []
      node.css('xs|attribute').each do |a|
        attr_name = a.attr("name")
        attr_type = without_namespace(a.attr("type"))
        attributes[attr_name] = attr_type
        compositions << a unless attr_type.nil?
      end
      node.css('xs|sequence').children.each do |a|
        next if a.instance_of?(Nokogiri::XML::Text)
        if a.name == "choice"
          a.children.each do |cc|
            next if cc.instance_of?(Nokogiri::XML::Text)
            a_name = cc.attr("name") || cc.attr("ref")
            a_type = cc.attr("type") || cc.attr("ref")
            a_type = without_namespace(a_type)
            compositions << cc unless a_type.nil?
            methods << MustacheViews::ClassMethod.new(a_name, a_type)
          end
        else
          a_name = a.attr("name") || a.attr("ref")
          a_type = without_namespace(a.attr("type") || a.attr("ref"))
          compositions << a unless a_type.nil?
          methods << MustacheViews::ClassMethod.new(a_name, a_type)
        end
      end

      label = MustacheViews::ClassLabel.new(name, node.name, attributes, methods).render
      graph.nodes << MustacheViews::Node.new(name, "label" => label)

      compositions.each do |el|
        comp = without_namespace(el.attr("type") || el.attr("ref"))
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
        graph.nodes << MustacheViews::EdgeNode.new(comp, name, "arrowhead" => "diamond", "taillabel" => edge_label)
      end

      graph
    end

    def add_simple_type(node, graph)
      name = node.attr("name")
      stereotype = node.css('xs|enumeration').empty? ? node.name : "enumeration"
      enumerations = []
      restrictions = []
      types = []
      if (restriction = node.css('xs|restriction').first)
        specialization = MustacheViews::Restriction.new(restriction.name, restriction.attr("base"))
        restriction.children.each do |child|
          case child.name
          when 'enumeration'
            enumerations << child.attr("value")
          when 'text'
          else
            restrictions << "#{child.name}: #{child.attr("value")}"
          end
        end
      end
      unless node.css('xs|union').empty?
        node.css('xs|union').attr("memberTypes").value.split(" ").each do |union_type|
          types << union_type
          union_type = without_namespace(union_type)
          next if %w(string link date boolean integer int).include?(union_type)
          graph.nodes << MustacheViews::EdgeNode.new(union_type, name, "arrowhead" => "diamond", "taillabel" => "1")
        end
        stereotype = "union"
        specialization = nil # MustacheViews::Union.new("union", types)
      end
      specialization = node.css('xs|list') if specialization == ""
      class_label = MustacheViews::ClassLabel.new(name, stereotype) # , {}, []) #, enumerations)
      class_label.lines << MustacheViews::SimpleType.new(
        specialization, restrictions, types, enumerations)
      label = class_label.render
      graph.nodes << MustacheViews::Node.new(name, "label" => label)
      graph
    end

    def populate_graph(graph, xsd)
      xsd.css('xs|schema').children.each do |node|
        graph =
        case node.name
        when 'element'
          add_element(node, graph)
        when 'complexType'
          add_complex_type(node, graph)
        when 'simpleType'
          add_simple_type(node, graph)
        else
          graph
        end
      end
      graph
    end

    def determine_schema_prefix(xsd)
      @prefix = xsd.root.namespace.prefix
    end

    def draw(infile)
      xsd = Nokogiri::XML(File.read(infile))
      schema_name = File.basename(infile, ".xsd")
      graph = create_graph(schema_name)
      determine_schema_prefix(xsd)
      graph = populate_graph(graph, xsd)

      outfile = "#{schema_name}.dot"
      File.open(outfile, "w") do |f|
        f.write(graph.render)
      end
    end
  end
end
