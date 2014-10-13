require "parslet"

module Umlit
  class NetworkArchitectureParser < Parslet::Parser
    # Begin Basic Rules
    rule(:colon) { spaces? >> str(':') >> spaces? }
    rule(:comma) { spaces? >> str(',') >> spaces? }
    rule(:comment) { spaces? >> str('#') >> match('[^\n]').repeat >> spaces? }
    rule(:digit) { match('[0-9]') }

    rule(:integer) do
      (str('0') | (match('[1-9]') >> digit.repeat))
    end

    rule(:spaces) { match('\s').repeat(1) }
    rule(:spaces?) { spaces.maybe }

    rule(:string) do
      str('"') >> (
        str('\\') >> any | str('"').absent? >> any
      ).repeat.as(:string) >> str('"')
    end

    # Begin structure rules
    rule(:body) { str("body") >> colon >> string.as(:body) }

    rule(:connection_type_def) do
      str("type") >> spaces? >> colon >> spaces? >> connection_type_list
    end

    rule(:connection_type_list) do
      (connection_type >>
        (comma >> connection_type).repeat).as(:connection_types) >> spaces?
    end

    rule(:connection_type) do
      (str("fiber") | str("failover") | str("wan") | str("backup") |
        str("exnet")).as(:connection_type) >> spaces?
    end

    rule(:icons) { str("icons") >> colon >> icon_list >> spaces? }

    rule(:icon_list) do
      spaces? >>
      (icon_name >> (comma >> icon_name).repeat).maybe.as(:icons) >> spaces?
    end

    rule(:icon_name) { match('\w').repeat(1).as(:icon) }

    rule(:io_body) do
      str("{") >> spaces? >> connection_type_def >>
      spaces? >> target >> spaces? >> str("}") >> spaces?
    end

    rule(:io_def) do
      (str("output") | str("input")).as(:direction) >> colon >>
      (connection_type_list | node_name | io_body.repeat).as(:type) >> spaces?
    end

    rule(:node_body) do
      str("{") >> spaces? >> title.maybe >> spaces? >>
      icons.maybe >> spaces? >>
      (node_def.as(:node).repeat).as(:nodes) >> spaces? >>
      io_def.repeat >> spaces? >>
      note_def.maybe >> spaces? >> str("}")
    end

    rule(:node_count) do
      str("(") >> spaces? >>
        integer.as(:node_count) >> spaces? >> str(")") >> spaces?
    end

    rule(:node_def) do
      node_type >> (spaces >> node_name).maybe >>
      colon >> (node_body | node_title | node_count | node_name) >> spaces?
    end

    rule(:node_list) do
      (node_name >> (comma >> node_name).repeat).as(:node_list) >> spaces?
    end

    rule(:node_name) { match('[\w\d]').repeat(1).as(:node_name) }

    rule(:node_title) do
      string.as(:title) >> node_count.maybe >> spaces?
    end

    rule(:node_type) do
      (str("vmSegment") | str("vmWareEsx") |
        str("cloudServers") | str("group") | str("haPair") | str("ispCloud") |
        str("privateCloud") | str("root") | str("san") | str("segment") |
        str("server") | str("vm") | str("alertLogic") | str("ciscoFirewall") |
        str("f5LoadBalancer") | str("routingHardware")).as(:node_type)
    end

    rule(:target) { str("target") >> colon >> node_list }

    rule(:title) { str("title") >> colon >> string.as(:title) >> spaces? }

    rule(:note_body) do
      str("{") >> spaces? >> title.maybe >> spaces? >>
      body.maybe >> spaces? >> str("}") >> spaces?
    end

    rule(:note_def) { str("note") >> colon >> note_body.as(:note) }

    rule(:top) do
      spaces? >> comment.repeat >>
      (node_def.as(:node).repeat).as(:nodes) >> spaces?
    end

    root(:top)
  end
end
