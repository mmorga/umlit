module Umlit
  module Flowchart
    # The FlowchartTransformer class is responsible for taking
    # the raw parse tree from Parslet and transforming it into an easier to
    # consume AST
    class FlowchartTransformer < Parslet::Transform
      rule(node: subtree(:node)) do
        if node.instance_of?(Hash)
          Node.new(node)
        else
          FlowBreak.new
        end
      end
    end
  end
end
