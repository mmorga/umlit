require 'test_helper'

module Umlit
  class TestNetworkHashNormalizer < MiniTest::Test
    def setup
      @normalizer = NetworkHashNormalizer.new
    end

    def test_pass_through_case
      hash = {
        nodes: [
          node: {
            title: "Hello",
            node_type: "normal",
            nodes: []
          }
        ]
      }
      assert @normalizer.normalize(hash) == hash
    end
  end
end
