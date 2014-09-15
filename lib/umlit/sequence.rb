module Umlit
  class Sequence
    attr_accessor :title, :rows, :actors, :interactions, :activations, :notes

    def initialize
      @title = ""
      @rows = []
      @actors = []
      @interactions = []
      @activations = {}
      @notes = []
    end

    def actors_index(actor)
      @actors.index(actor)
    end
  end
end
