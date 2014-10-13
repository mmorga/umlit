require 'test_helper'

class TestNetworkArchitectureParser < MiniTest::Unit::TestCase
  def setup
    @parser = NetworkArchitectureParser.new
  end

  def test_comment
    assert @parser.comment.parse("# nskl 08 -+!@#$%^&*()")
  end

  def test_connection_type_def
    assert @parser.connection_type_def.parse("type : fiber, wan , exnet\n\n")
    assert @parser.connection_type_def.parse("type: fiber, failover\n")
  end

  def test_connection_type_list
    %w(fiber failover wan backup exnet).each do |c|
      assert @parser.connection_type_list.parse("#{c}"), "connection_type should parse '#{c}'"
    end

    assert @parser.connection_type_list.parse("fiber , failover,wan")
  end

  def test_icons
    assert @parser.icons.parse("icons: one, two, three")
    assert @parser.icons.parse("icons: one, two, three\n   \n")
  end

  def test_io_def
    assert @parser.io_def.parse("input: exnet\n   \n")
  end

  def test_io_def_with_io_body
    assert @parser.io_def.parse("output: {\n type: fiber, failover\n target: publicSegment1, publicSegment2\n}")
  end

  def test_io_def_with_node_name
    assert @parser.io_def.parse("output: myNode_0\n")
  end

  def test_node_count
    res = @parser.node_count.parse('(2)')
    assert res[:node_count] == "2"
    res = @parser.node_count.parse('( 3 )')
    assert res[:node_count] == "3"
    res = @parser.node_count.parse('( 4 ) ')
    assert res[:node_count] == "4"
  end

  def test_node_def
    assert @parser.node_def.parse("routingHardware: (2)\n")
    assert @parser.node_def.parse("privateCloud: privateCloud1\n")

    %w(cloudServers group haPair ispCloud privateCloud root san segment server
       vm alertLogic ciscoFirewall f5LoadBalancer routingHardware vmWareEsx
       vmSegment network).each do |nt|
      assert @parser.node_def.parse("#{nt}: (2)"), nt
      assert @parser.node_def.parse("#{nt}: \"VMWare ESX Host\""), nt
      assert @parser.node_def.parse("#{nt}: \"VMWare ESX Host\"(2)"), nt
    end
    # Works: cloudServers group haPair ispCloud privateCloud
  end

  def test_node_list
    assert @parser.node_list.parse("node1, node2 ,node3")
    assert @parser.node_list.parse("node1, node2 ,node3\n")
  end

  def test_node_name
    assert @parser.node_name.parse("my_Node_Name0")
  end

  def test_node_title
    res = @parser.node_title.parse('"VMWare ESX Host"(2) ')
    assert res
  end

  def test_node_type
    %w(cloudServers group haPair ispCloud privateCloud root san segment server
       vm alertLogic ciscoFirewall f5LoadBalancer routingHardware vmWareEsx
       vmSegment network).each do |nt|
      assert @parser.node_type.parse(nt)
    end
  end

  def test_note_def
    assert @parser.note_def.parse(<<-NOTE
note: {
  title: "This is my title"
  body: "This is my
  multi line body
  yay"
}
NOTE
)
  end

  def test_integer
    assert @parser.integer.parse("12")
    assert @parser.integer.parse("3")
    assert_raises(Parslet::ParseFailed) { @parser.integer.parse("1.5") }
  end

  def test_io_def_with_connection_type_list
    %w(fiber failover wan backup exnet).each do |c|
      assert @parser.io_def.parse("output: #{c}\n")
    end
  end

  def test_spaces
    assert @parser.spaces.parse(" ")
    assert @parser.spaces.parse("   ")
  end

  def test_target
    assert @parser.target.parse("target : someNodeName\n")
    assert @parser.target.parse("target : someNodeName , someNode2\n")
    assert @parser.target.parse("target: publicSegment1, publicSegment2\n")
  end
end
