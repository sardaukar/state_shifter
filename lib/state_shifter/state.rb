module StateShifter

  class State

    attr_reader :name, :events, :initial
    attr_accessor :entry_callback, :entry_callback_args

    def initialize name, initial=false
      @name = name
      @events = {}
      @initial = initial
      @entry_callback = nil
      @entry_callback_args = nil
    end

    def has_entry_callback?
      !@entry_callback.nil?
    end

    def initial?
      @initial
    end

    def final?
      @events.empty?
    end

    def draw graph, options
      node = graph.add_nodes(@name.to_s,
                            :label => @name.to_s,
                            :width => '1',
                            :height => '1',
                            :shape => final? ? 'doublecircle' : 'ellipse'
                           )

      graph.add_edges(graph.add_nodes('starting_state', :shape => 'point'), node) if initial?

      node
    end

  end

end
