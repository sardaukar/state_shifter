module StateShifter

  module Definition

    module InstanceMethods

      attr_accessor :current_state, :state_machine_definition

      def initialize
        @current_state = state_machine_definition.initial_state.name.to_sym
        @subject = self
      end

      def state_machine_definition
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
        state_machine_definition.initial_state.name
      end

      def names_for what
        state_machine_definition.send(what).collect {|name, definition| name }
      end

      def check_event_callbacks event_name
        event_def = state_machine_definition.get(:event, event_name)
        begin
          @subject.send event_def.callback
        rescue NoMethodError
          raise ::StateShifter::CallbackMethodNotDefined, event_def.callback
        end
      end

      def current_state_def
        state_machine_definition.get(:state, @current_state)
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
          @subject.instance_exec(old_state, trigger.to_sym, &proc_or_method_name)
        end        
      end

      def transition args
        _start = Time.now

        # BOOP!
        old_state = @current_state
        @current_state = args[:to].to_sym
        #

        check_event_callbacks(args[:trigger]) if state_machine_definition.get(:event, args[:trigger]).has_callback?

        call_state_entry_callback(args[:trigger], old_state) if current_state_def.has_entry_callback?
        
        @subject.instance_exec(old_state, @current_state, args[:trigger].to_sym, (Time.now - _start), &state_machine_definition.on_transition_proc) if state_machine_definition.has_on_transition_proc?
        true
      end

      def halt message
        raise ::StateShifter::TransitionHalted, message
      end

      def check_guards event_name
        event = state_machine_definition.get(:event, event_name)

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
