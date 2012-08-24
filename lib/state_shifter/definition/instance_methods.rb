module StateShifter

  module Definition

    module InstanceMethods

      class ::StateShifter::TransitionHalted < Exception ; end
      class ::StateShifter::GuardMethodUndefined < Exception ; end
      class ::StateShifter::GuardNotSatisfied < Exception ; end
      class ::StateShifter::CallbackMethodNotDefined < Exception ; end
      class ::StateShifter::RedifiningEvent < Exception ; end
      class ::StateShifter::RedifiningState < Exception ; end

      attr_accessor :current_state, :definition

      def initialize
        @current_state = definition.initial_state.name.to_sym
        @subject = self
      end

      def definition
        self.class.state_machine_definition
      end

      def next_states
        _next_states current_state
      end

      def transitionable_states
        _next_states current_state, {:check_guards => true}
      end

      def state_names
        names_for :states
      end

      def event_names
        names_for :events
      end

      def initial_state
        definition.initial_state.name
      end

      #######
      private
      #######

      def names_for what
        definition.send(what).collect {|name, definition| name }
      end

      def check_event_callbacks event_name
        event_def = definition.get(:event, event_name)
        begin
          @subject.send event_def.callback
        rescue NoMethodError
          raise ::StateShifter::CallbackMethodNotDefined, event_def.callback
        end
      end

      def current_state_def
        definition.get(:state, @current_state)
      end

      def call_state_entry_callback trigger, old_state
        proc_or_method_name = current_state_def.entry_callback

        if proc_or_method_name.is_a?(Symbol)
          begin
            @subject.send proc_or_method_name  
          rescue NoMethodError
            raise ::StateShifter::CallbackMethodNotDefined, proc_or_method_name
          end
        else
          @subject.instance_exec(old_state, trigger, &proc_or_method_name)
        end        
      end

      def transition args
        _start = Time.now
        # BOOP!
        old_state = @current_state
        @current_state = args[:to].to_sym

        check_event_callbacks(args[:trigger]) if definition.get(:event, args[:trigger]).has_callback?

        call_state_entry_callback(args[:trigger], old_state) if current_state_def.has_entry_callback?
        
        @subject.instance_exec(old_state, @current_state, args[:trigger], (Time.now - _start), &definition.on_transition_proc) if definition.has_on_transition_proc?
        true
      end

      def halt message
        raise ::StateShifter::TransitionHalted, message
      end

      def check_guards event_name
        event = definition.get(:event, event_name)

        if event.has_guards?
          event.guards.each do |guard|
            begin
              return false, guard unless self.send(guard.to_sym)
            rescue NoMethodError
              raise ::StateShifter::GuardMethodUndefined, guard
            end
          end
          true
        else
          true
        end
      end

    end
  end

end
