require "nokogiri"

# TODO: handle annotations - notes?
# TODO: handle namespaces - option to put namespaces in a cluster
# TODO: handle schema imports - how? what? related to namespaces
# TODO: Add an option to export only the items related to a single element or type
module Umlit
  class XsdClassDiagram
    attr_reader :xsd, :root_schema_file, :graph, :included_schema_files
    attr_accessor :include_schemas

    DEFAULT_OPTS = {
      include_schemas: true # Include schemas referenced in an include element in the diagram
    }
    def initialize(opts = {})
      @xsd = nil
      @root_schema_file = nil
      @graph = nil
      @included_schema_files = Set.new

      options = DEFAULT_OPTS.merge(opts)
      @include_schemas = options[:include_schemas]
    end

    def self.create(infile, opts = {})
      xsd_class_diagram = new(opts)
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
      @graph = MustacheViews::Graph.new(name)
      graph.nodes << graph_settings
      graph.nodes << node_settings
      graph.nodes << edge_settings
    end

    def without_namespace(str)
      return nil if str.nil?
      str.sub("#{@target_prefix}:", '')
    end

    def add_element(node)
      name = node.attr("name")
      type = without_namespace(node.attr("type"))
      label = MustacheViews::ClassLabel.new(name, node.name).render
      graph.nodes << MustacheViews::Node.new(name, "label" => label)
      graph.nodes << MustacheViews::EdgeNode.new(name, type, "arrowhead" => "onormal")
    end

    # TODO: refactor this big mess
    def add_complex_type(node)
      name = node.attr("name")
      # type = without_namespace(node.attr("type"))
      compositions = []
      attributes = {}
      methods = []
      node.css('attribute').each do |a|
        attr_name = a.attr("name")
        attr_type = without_namespace(a.attr("type"))
        attributes[attr_name] = attr_type
        compositions << a unless attr_type.nil?
      end
      node.css('sequence').children.each do |a|
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
        next if outside_target_namespace?(comp)
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
    end

    def add_simple_type(node)
      name = node.attr("name")
      stereotype = node.css('enumeration').empty? ? node.name : "enumeration"
      enumerations = []
      restrictions = []
      types = []
      if (restriction = node.css('restriction').first)
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
      unless node.css('union').empty?
        node.css('union').attr("memberTypes").value.split(" ").each do |union_type|
          union_type = without_namespace(union_type)
          types << union_type
          next if outside_target_namespace?(union_type)
          graph.nodes << MustacheViews::EdgeNode.new(union_type, name, "arrowhead" => "diamond", "taillabel" => "1")
        end
        stereotype = "union"
        specialization = nil
      end
      specialization = node.css('list') if specialization == ""
      class_label = MustacheViews::ClassLabel.new(name, stereotype)
      class_label.lines << MustacheViews::SimpleType.new(
        specialization, restrictions, types, enumerations)
      label = class_label.render
      graph.nodes << MustacheViews::Node.new(name, "label" => label)
    end

    def outside_target_namespace?(name)
      parts = name.split(":")
      parts.size > 1 && parts.first != @target_prefix
    end

    def populate_graph
      xsd.css('schema').children.each do |node|
        case node.name
        when 'element'
          add_element(node)
        when 'complexType'
          add_complex_type(node)
        when 'simpleType'
          add_simple_type(node)
        end
      end
    end

    def collect_included_files
      return unless include_schemas
      xsd.css('include').map do |i|
        included_schema_files.add(i.attr('schemaLocation'))
      end
    end

    def add_schema_file_to_graph(filename)
      @xsd = Nokogiri::XML(File.read(filename))
      xsd.root.default_namespace = xsd.root.namespace.href
      @target_prefix = xsd.root.namespaces.key(xsd.root.attr("targetNamespace")).sub(/.+:/, '')
      collect_included_files
      populate_graph
    end

    def draw(infile)
      @root_schema_file = infile
      @schema_directory = File.dirname(infile)
      schema_name = File.basename(infile, ".xsd")
      create_graph(schema_name)

      add_schema_file_to_graph(infile)

      included_schema_files.each do |f|
        add_schema_file_to_graph(File.join(@schema_directory, f))
      end
      outfile = "#{schema_name}.dot"
      File.open(outfile, "w") do |f|
        f.write(graph.render)
      end
    end
  end
end
