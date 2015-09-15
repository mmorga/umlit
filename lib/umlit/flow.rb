flowchart = {
  sections: [
    {
      id: "sec1",
      label: "Beginning"
    },
    {
      id: "sec2",
      label: "Ending"
    }
  ],
  swimlanes: [
    {
      id: "swim1",
      label: "System 1"
    },
    {
      id: "swim2",
      label: "System 2"
    }
  ],
  nodes: [
    {
      id: "node1",
      label: "Begin",
      type: :start,
      swimlane: "swim1",
      section: "sec1",
      outputs: {
        target: "node3",
        label: "read event"
      }
    },
    {
      id: "node3",
      label: "consume event",
      type: :process,
      swimlane: "swim1",
      section: "sec1",
      outputs: {
        target: "node5"
      }
    },
    {
      id: "node5",
      label: "Working",
      type: :decision,
      swimlane: "swim1",
      section: "sec2",
      outputs: [
        {
          target: "node11",
          label: "yes"
        },
        {
          target: "node8",
          label: "no"
        }
      ]
    },
    {
      id: "node8",
      label: "Fix it",
      type: :process,
      swimlane: "swim2",
      section: "sec2",
      outputs: {
        target: "node11",
        label: "fixed"
      }
    },
    {
      id: "node11",
      label: "End",
      type: :end,
      swimlane: "swim2",
      section: "sec2"
    }
  ]
}

class FlowchartGridLayout
  attr_accessor :node_hash
# maybe read the nodes into a hash with id for key
node_hash = flowchart[:nodes].reduce({}) do |memo, obj|
  memo[obj[:id]] = obj
  memo
end

cur_pos = [0, 0]
first = flowchart[:nodes].first

position_node(first)
position_targets(first)

 do |node, i|
  if i == 0
    node[:position] = cur_pos
    next
  end

end
