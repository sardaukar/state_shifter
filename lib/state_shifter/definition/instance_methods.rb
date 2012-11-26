module StateShifter
  module Definition
    module InstanceMethods

      def current_state
        get_current_state
      end

      def get_current_state
        instance_variable_defined?(:@current_state) ? @current_state.to_sym : state_machine_definition.initial_state.name.to_sym
      end

      def set_current_state value
        @current_state = value.to_sym
      end

      def state_machine_definition
        self.class.state_machine_definition
      end

      def next_states
        _next_states get_current_state
      end

      def transitionable_states
        _next_states get_current_state, {:check_guards => true}
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
        state_machine_definition.send(what).collect {|name, definition| name.to_sym }
      end

      def check_event_callbacks event_name
        event_def = state_machine_definition.get(:event, event_name)
        begin
          self.send event_def.callback
        rescue NoMethodError
          raise CallbackMethodNotDefined, event_def.callback
        end
      end

      def current_state_def
        state_machine_definition.get(:state, get_current_state)
      end

      def call_state_entry_callback trigger, old_state
        proc_or_method_name = current_state_def.entry_callback

        if proc_or_method_name.is_a?(Symbol)
          method_args = current_state_def.entry_callback_args
          begin
            if method_args
              self.send proc_or_method_name, method_args
            else
              self.send proc_or_method_name
            end
          rescue NoMethodError
            raise CallbackMethodNotDefined, proc_or_method_name
          end
        else
          self.instance_exec(old_state, trigger.to_sym, &proc_or_method_name)
        end
      end

      def transition args
        _start = Time.now

        # BOOP!
        old_state = get_current_state
        set_current_state args[:to]
        #

        self.instance_exec(old_state, get_current_state, args[:trigger].to_sym, (Time.now - _start), &state_machine_definition.on_transition_proc) if state_machine_definition.has_on_transition_proc?

        call_state_entry_callback(args[:trigger], old_state) if current_state_def.has_entry_callback?

        check_event_callbacks(args[:trigger]) if state_machine_definition.get(:event, args[:trigger]).has_callback?

        true
      end

      def halt message
        raise TransitionHalted, message
      end

      def check_guards event_name
        event = state_machine_definition.get(:event, event_name)

        if event.has_guards?
          event.guards.each do |guard|
            begin
              return false, guard unless self.send(guard.to_sym)
            rescue NoMethodError
              raise GuardMethodUndefined, guard
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
