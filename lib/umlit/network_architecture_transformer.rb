module Umlit
  # The NetworkArchitectureTransformer class is responsible for taking
  # the raw parse tree from Parslet and transforming it into an easier to
  # consume AST
  class NetworkArchitectureTransformer < Parslet::Transform
    # The Node class contains the attributes for a single node
    # of some kind built from the Parse Tree Transform.
    class Node
      attr_accessor :node_name, :node_type, :node_count, :nodes
      attr_accessor :icons, :direction, :type, :title, :note
      def self.create(src)
        if src.instance_of?(Hash)
          create_from_hash(src)
        elsif src.instance_of?(Array)
          create_from_array(src)
        else
          puts "Unexpected source type for Node: #{src.class}"
        end
      end

      def self.create_from_array(src)
        h = src.reduce({}) { |a, e| a.merge(e) }
        puts h.inspect
        create_from_hash(h)
      end

      def self.create_from_hash(h)
        node = Node.new
        h.keys.each do |sym|
          node.send("#{sym}=", h[sym]) if h.include?(sym)
        end
        node
      end

      def initialize
        @node_name = ""
        @title = ""
        @node_type = ""
        @direction = ""
        @type = ""
        @node_count = 0
        @note = {}
        @nodes = []
        @icons = []
      end

      # Returns a hash, that will be turned into a JSON object and represent this
      # object.
      def as_json(*)
        {
          JSON.create_id => self.class.name,
          node_name: node_name, node_type: node_type,
          node_count: node_count, nodes: nodes,
          icons: icons, direction: direction,
          type: type, title: title,
          note: note
        }
      end

      def to_json(*args)
        as_json.to_json(*args)
      end
    end

    rule(connection_type: simple(:x)) { x }
    rule(string: simple(:st)) { st.to_s }
    rule(title: simple(:s)) { s }
    rule(node: subtree(:node)) { Node.create(node) }
  end
end
