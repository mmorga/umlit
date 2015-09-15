module Umlit
  class DiagramWorkflow
    def initialize(input, pre_process, layout, post_process, output, style)
      @input = input
      @pre_process = pre_process
      @layout = layout
      @post_process = post_process
      @output = output
      @style = style
    end

    # Call each step of the workflow catching any errors
    def process
    end
  end
end
