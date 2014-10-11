require "parslet"

class NetworkArchitectureParser < Parslet::Parser
  rule(:spaces) { match('\s').repeat(1) }
  rule(:spaces?) { spaces.maybe }

  rule(:comma) { spaces? >> str(',') >> spaces? }
  rule(:colon) { spaces? >> str(':') >> spaces? }
  rule(:digit) { match('[0-9]') }

  rule(:number) do
    (
      str('-').maybe >> (
        str('0') | (match('[1-9]') >> digit.repeat)
      ) >> (
        str('.') >> digit.repeat(1)
      ).maybe >> (
        match('[eE]') >> (str('+') | str('-')).maybe >> digit.repeat(1)
      ).maybe
    ).as(:number)
  end

  rule(:string) do
    str('"') >> (
      str('\\') >> any | str('"').absent? >> any
    ).repeat.as(:string) >> str('"')
  end

  rule(:input_def) { str("input") >> colon >> (connection_type_list | node_name | io_body.repeat).as(:input) >> spaces? }

  rule(:output_def) { str("output") >> colon >> (connection_type_list | node_name | io_body.repeat).as(:output) >> spaces? }

  rule(:icons) { str("icons") >> colon >> icon_list >> spaces? }

  rule(:icon_list) do
    spaces? >> (icon_name >> (comma >> icon_name).repeat).maybe.as(:icon_list) >> spaces?
  end

  rule(:icon_name) { match('\w').repeat(1).as(:icon_name) }

  rule(:note_def) { str("note") >> colon >> note_body.as(:note) }

  rule(:note_body) do
    str("{") >> spaces? >> title.maybe.as(:title) >> spaces? >>
    body.maybe.as(:body) >> spaces? >> str("}") >> spaces?
  end

  rule(:body) do
    str("body") >> colon >> multi_line_indented_string
  end

  rule(:node_name) { match('[\w\d]').repeat(1).as(:node_name) }

  rule(:node_type) do
    str("vmSegment") | str("vmWareEsx") |
    str("cloudServers") | str("group") | str("haPair") | str("ispCloud") |
    str("privateCloud") | str("root") | str("san") | str("segment") |
    str("server") | str("vm") | str("alertLogic") | str("ciscoFirewall") |
    str("f5LoadBalancer") | str("routingHardware") | str("network")
  end

  rule(:node_def) do
    node_type.as(:node_type) >> (spaces >> node_name).maybe >>
    colon >> (node_body | node_title | node_count | node_name) >> spaces?
  end

  rule(:node_body) do
    str("{") >> spaces? >> title.maybe >> spaces? >>
    icons.maybe >> spaces? >>
    (node_def.repeat).as(:nodes) >> spaces? >>
    input_def.repeat >> spaces? >> output_def.repeat >> spaces? >>
    note_def.maybe >> spaces? >> str("}")
  end

  rule(:node_title) do
    string.as(:node_title) >> node_count.maybe >> spaces?
  end

  rule(:node_count) do
    str("(") >> spaces? >> number.as(:node_count) >> spaces? >> str(")") >> spaces?
  end

  rule(:node_list) do
    (node_name >> (comma >> node_name).repeat).as(:node_list) >> spaces?
  end

  rule(:target) { str("target") >> colon >> node_list }
  rule(:title) { str("title") >> colon >> string.as(:title) >> spaces? }

  rule(:connection_type_def) { str("type") >> spaces? >> colon >> spaces? >> connection_type_list }
  rule(:connection_type_list) do
    (connection_type >> (comma >> connection_type).repeat).as(:connection_type_list) >> spaces?
  end
  rule(:connection_type) do
    (str("fiber") | str("failover") | str("wan") | str("backup") |
      str("exnet")).as(:connection_type) >> spaces?
  end

  # TODO: think about how to define this better
  rule(:multi_line_indented_string) { string.as(:multi_line_indented_string) }
  rule(:io_body) do
    str("{") >> spaces? >> connection_type_def >>
    spaces? >> target >> spaces? >> str("}") >> spaces?
  end

  rule(:top) { spaces? >> node_def >>  spaces? }

  root(:top)
end

# class Transformer < Parslet::Transform

#   class Entry < Struct.new(:key, :val); end

#   rule(:array => subtree(:ar)) {
#     ar.is_a?(Array) ? ar : [ ar ]
#   }
#   rule(:object => subtree(:ob)) {
#     (ob.is_a?(Array) ? ob : [ ob ]).inject({}) { |h, e| h[e.key] = e.val; h }
#   }

#   rule(:entry => { :key => simple(:ke), :val => simple(:va) }) {
#     Entry.new(ke, va)
#   }

#   rule(:string => simple(:st)) {
#     st.to_s
#   }
#   rule(:number => simple(:nb)) {
#     nb.match(/[eE\.]/) ? Float(nb) : Integer(nb)
#   }

#   rule(:null => simple(:nu)) { nil }
#   rule(:true => simple(:tr)) { true }
#   rule(:false => simple(:fa)) { false }
# end

# def self.parse(s)

#   parser = Parser.new
#   transformer = Transformer.new

#   tree = parser.parse(s)
#   puts; p tree; puts
#   out = transformer.apply(tree)

#   out
# end
