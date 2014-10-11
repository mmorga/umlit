require 'minitest/autorun'
require "umlit"
require "json"

class TestNetworkArchitectureParser < MiniTest::Unit::TestCase
  def setup
    @parser = NetworkArchitectureParser.new
  end

  def test_that_spaces_work
    assert @parser.spaces.parse(" ")
    assert @parser.spaces.parse("   ")
  end

  def test_icons
    assert @parser.icons.parse("icons: one, two, three")
    assert @parser.icons.parse("icons: one, two, three\n   \n")
  end

  def test_input_def
    assert @parser.input_def.parse("input: exnet\n   \n")
  end

  def test_node_def
    assert @parser.node_def.parse("routingHardware: (2)\n")
  end

  def test_connection_type_def
    assert @parser.connection_type_def.parse("type : fiber, wan , exnet\n\n")
  end

  def test_target
    assert @parser.target.parse("target : someNodeName\n")
    assert @parser.target.parse("target : someNodeName , someNode2\n")
    assert @parser.target.parse("target: publicSegment1, publicSegment2\n")
  end

  def test_node_list
    assert @parser.node_list.parse("node1, node2 ,node3")
    assert @parser.node_list.parse("node1, node2 ,node3\n")
  end

  def test_output_def_with_io_body
    assert @parser.output_def.parse("output: {\n type: fiber, failover\n target: publicSegment1, publicSegment2\n}")
  end

  def test_output_def_with_connection_type_list
    %w(fiber failover wan backup exnet).each do |c|
      assert @parser.output_def.parse("output: #{c}\n")
    end
  end

  def test_output_def_with_node_name
    assert @parser.output_def.parse("output: myNode_0\n")
  end

  def test_connection_type_list
    %w(fiber failover wan backup exnet).each do |c|
      assert @parser.connection_type_list.parse("#{c}"), "connection_type should parse '#{c}'"
    end

    assert @parser.connection_type_list.parse("fiber , failover,wan")
  end

  def test_connection_type_def
    assert @parser.connection_type_def.parse("type: fiber, failover\n")
  end

  def test_node_name
    assert @parser.node_name.parse("my_Node_Name0")
  end

  def test_big_one
    sample = <<-SAMPLE
network: {
  title: "Polaris & Utility Grid Production - IAD3 Data Center"

  root: {
    title: "Elk Grove Village IL"

    ispCloud: {
      icons: qwest, teliasonera, abovenet, level3, equinix
      output: wan
    }

    haPair: {
      title: "Internet Routing Layer"
      routingHardware: (2)
      output: exnet
    }

    haPair: {
      title: "Aggregate Switching Layer"
      routingHardware: (2)
      input: exnet
    }

    output: {
      type: fiber, failover
      target: publicSegment1, publicSegment2
    }
  }

  segment publicSegment1: {
    title: "Public Network Segment"
    haPair: {
      title: "Cisco ASA 5520 Firewall (HA Redundant Pair)"
      ciscoFirewall: (2)
    }
    haPair: {
      title: "Alert Logic Threat Manager IDS (HA Redundant Pair)"
      alertLogic: (2)
    }
    haPair: {
      title: "Alert Logic Log Manager"
      f5LoadBalancer: (2)
    }
    output: {
      type: fiber, failover
      target: productionPciDmz, productionPciInside
    }
   }
  privateCloud privateCloud1: {
    title: "VM Resource Pool: 64 Physical Cores 512GB RAM 500GB SAN Storage"
    vmWareEsx: "VMWare ESX Host"(2)
  }

  segment productionPciDmz: {
    title: "Production PCI Segment - DMZ"
    privateCloud: privateCloud1
    vmSegment: {
      title: "Production DMZ PCI Segment VM's"
      vm: "Billing Proxy VM (Production)"
      vm: "Billing Proxy VM (Production)"
      vm: "Payment Proxy VM (Production)"
      vm: "Payment Proxy VM (Production)"
    }
    output: {
      {
        type: fiber, failover
        target: sanFiberNetwork
      }
      {
        type: backup
        target: backupNetwork
      }
    }
  }

  segment productionPciInside: {
    title: "Production PCI Segment - Inside"
    privateCloud: privateCloud1
    vmSegment: {
      title: "Production Inside PCI Segment VM's"
      vm: "Billing Service VM (Production)"
      vm: "Billing Service VM (Production)"
      vm: "Payment Service VM (Production)"
      vm: "Payment Service VM (Production)"
      vm: "Payment Service VM (Production)"
      vm: "Payment Service VM (Production)"
      vm: "Web App VM (Production)"
      vm: "Web App VM (Production)"
    }
    output: {
      {
        type: fiber, failover
        target: sanFiberNetwork
      }
      {
        type: backup
        target: backupNetwork
      }
    }
  }
}
SAMPLE
    begin
      res = @parser.root.parse(sample)
      assert res
      puts JSON.pretty_generate(res)
    rescue Parslet::ParseFailed => failure
      fail failure.cause.ascii_tree
    end
  end
end
