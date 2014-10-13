class Node
  attr_reader :name

  def initialize(parent, name)
    @parent = parent
    @name = name
  end

  def message(target, msg = "")
    msg_str = "  #{@name}->#{target.name}"
    msg_str << " [label=\"#{msg.gsub("\n", "\\n")}\"]" unless msg.empty?
    msg_str << ";"
    @parent.add_content msg_str
  end
end

# A simple tasks executer
# This code is very basic and could be far optimized
class SoaDiagram
  attr_reader :title, :graph_id, :nodes
  def initialize
    @title = "title"
    @graph_id = @title # TODO: need to convert to an ID
    puts "   **** SOA Diagram started ****"
    @packages = []
    @nodes = []
    @content = []
    @subgraph_idx = 0
  end

  # Start the diagram work
  def self.draw(&block)
    # Instantiate an executer object and evaluate the DSL code block
    diagram = new
    diagram.instance_eval(&block)
    diagram
  end

  def package(&block)
    @content << "  subgraph cluster#{@subgraph_idx} {"
    @content << "    labelloc=\"t\";"
    @content << "    bgcolor=\"#1680d3\";"
    @content << "    color=\"#0f3f74\";"
    @subgraph_idx += 1
    instance_eval(&block)
    @content << "  }"
  end

  def title(t)
    @title = t
    @content << "  label=\"#{t}\";"
  end

  def add_content(line)
    @content << line
  end
  # def package(title, &block)
  #   packages << Package.draw(title, block)
  # end

  def to_s
    puts "digraph #{graph_id} {"
    puts <<-STANDARD
  rankdir="LR";
  node [shape="umlcomponent";fontname="Helvetica-Bold";fontsize="14.0";color="#555555";fillcolor="#ffffff";style="filled";labelloc="b";labeljust="l";];
  edge [fontname="Helvetica";fontsize="12.0";];
  graph [fontname="Helvetica-Bold";style="rounded";labelloc="b"];
STANDARD
    @content.each { |l| puts l }
    puts "}"
  end

  def esc(label)
    label.gsub("\n", "\\n")
  end

  def person(label, *_args)
    "[label=\"#{esc(label)}\",image=\"person.png\",shape=\"plaintext\",height=\"0.75\",style=\"\"];"
  end

  def component(label, *_args)
    "[label=\"#{esc(label)}\"];"
  end

  def service(label, *_args)
    "[label=\"#{esc(label)}\",shape=\"umlservice\"];"
  end

  def datastore(label, *_args)
    "[label=\"#{esc(label)}\",shape=\"box\"];"
  end

  def method_missing(symbol, *args)
    puts "Method Missing: #{symbol}, #{args.inspect}"
    if args.empty?
      @nodes << symbol
      Node.new(self, symbol)
    else
      @content << "  #{symbol} #{args.join(" ")}"
    end
    # fail "StandardError",symbol.to_s
  end
end

puts res.to_s
