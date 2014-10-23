module Umlit
  module Flowchart
    class Decision
      attr_accessor :target_node, :message

      DEFAULT_HASH = { node: nil, message: "" }

      def initialize(hash = {})
        hash = DEFAULT_HASH.merge(hash)
        @target_node = hash[:node].instance_of?(Node) ? hash[:node] : Node.new(hash[:node])
        @message = hash[:message]
      end
    end
  end
end
