class NetworkArchitectureTransformer < Parslet::Transform
  # class Entry < Struct.new(:key, :val); end

  class Node
    attr_accessor :node_name, :node_title, :node_type, :node_count, :nodes
    def self.create(src)
      if src.instance_of?(Hash)
        create_from_hash(src)
      elsif src.instance_of?(Array)
        create_from_array(src)
      else
        puts "Unexpected source type for Node: #{src.class}"
      end
    end

    def self.create_from_hash(h)
      node = Node.new
      [:node_name, :node_title, :node_type, :node_count, :nodes].each do |sym|
        node.send("#{sym}=}", h[sym]) if h.include?(sym)
      end
      node
    end

    def initialize
      @node_name = @node_title = @node_type = ""
      @node_count = 0
      @nodes = []
    end
  end

  rule(connection_type: simple(:x)) { x }
  rule(string: simple(:st)) { st.to_s }
  rule(title: simple(:s)) { s }
  # rule(node: subtree(:no)) { puts no.inspect; no }
  # rule(array: subtree(:ar)) do
  #   ar.is_a?(Array) ? ar : [ar]
  # end
  # rule(object: subtree(:ob)) do
  #   (ob.is_a?(Array) ? ob : [ob]).each_with_object({}) do |h, e|
  #     h[e.key] = e.val
  #     h
  #   end
  # end

  # rule(entry: { key: simple(:ke), val: simple(:va) }) do
  #   Entry.new(ke, va)
  # end

  # rule(string: simple(:st)) do
  #   st.to_s
  # end
  # rule(number: simple(:nb)) do
  #   nb.match(/[eE\.]/) ? Float(nb) : Integer(nb)
  # end

  # rule(null: simple(:nu)) { nil }
  # rule(true: simple(:tr)) { true }
  # rule(false: simple(:fa)) { false }
end
