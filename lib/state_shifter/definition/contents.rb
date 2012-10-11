module StateShifter
  module Definition
    class Contents

      attr_accessor :states, :initial_state, :events, :on_transition_proc

      def initialize &definition
        @states = {}
        @events = {}
        instance_eval &definition if block_given?
      end

      def state name, &events_and_stuff
        if @states.empty? # first state declared is the initial one
          this_state = State.new(name, true)
          @initial_state = this_state
        else
          this_state = State.new(name)
        end

        raise RedifiningState, this_state.name if @states.has_key?(this_state.name.to_sym)

        @states[this_state.name.to_sym] = this_state
        @current_state = this_state
        instance_eval &events_and_stuff if events_and_stuff
      end

      def event hash_or_sym, hash=nil
        this_event =
          if hash.nil?
            if hash_or_sym.is_a?(Symbol)
              # looping event
              event_name = hash_or_sym

              Event.new @current_state.name.to_sym, event_name
            else
              # normal event
              event_guards = hash_or_sym.delete(:if)
              event_name = hash_or_sym.keys.first
              event_next_state = hash_or_sym[event_name.to_sym]

              Event.new @current_state.name.to_sym, event_name, event_next_state, event_guards
            end
          else
            event_guards = hash.delete(:if)
            event_name = hash_or_sym
            event_callback = hash.delete(:call)

            Event.new @current_state.name.to_sym, event_name, @current_state.name.to_sym, event_guards, event_callback
          end

        raise RedifiningEvent, this_event.name if @events.has_key?(this_event.name.to_sym)

        @events[this_event.name.to_sym] = this_event
        @current_state.events[event_name.to_sym] = this_event
      end

      def on_entry event_name=nil, *event_args, &proc_contents
        if event_name.nil?
          @current_state.entry_callback = proc_contents
        else
          @current_state.entry_callback = event_name
          @current_state.entry_callback_args = ( event_args.size == 1 ? event_args.first : event_args )
        end
      end

      def on_transition &proc_contents
        @on_transition_proc = proc_contents
      end

      ### end of DSL methods

      def get key, what
        case key
        when :event
          @events[what.to_sym] || @events[what.to_s.gsub('!','').to_sym]
        when :state
          @states[what.to_sym] || @states[what.to_s.gsub('!','').to_sym]
        end
      end

      def has_on_transition_proc?
        !@on_transition_proc.nil?
      end

    end
  end
end
