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

      #######
      private
      #######

      def check_event_callbacks event_name
        event_def = definition.events[event_name.to_sym]
        if event_def.has_callback?
          begin
            @subject.send event_def.callback
          rescue NoMethodError
            raise ::StateShifter::CallbackMethodNotDefined, event_def.callback
          end
        end
      end

      def current_state_def
        definition.states[@current_state.to_sym] 
      end

      def call_state_entry_callback trigger
        proc_or_method_name = current_state_def.entry_callback

        if proc_or_method_name.is_a?(Symbol)
          begin
            @subject.send proc_or_method_name  
          rescue NoMethodError
            raise ::StateShifter::CallbackMethodNotDefined, proc_or_method_name
          end
        else
          proc_or_method_name.call old_state, trigger
        end        
      end

      def transition args
        # BOOP!
        old_state = @current_state
        @current_state = args[:to].to_sym
        
        check_event_callbacks

        call_state_entry_callback(args[:trigger]) if current_state_def.has_entry_callback?
        
        definition.on_transition_proc.call old_state, @current_state, args[:trigger]
        true
      end

      def halt message
        raise ::StateShifter::TransitionHalted, message
      end

      def check_guards event_name
        event = self.class.state_machine_definition.events[event_name.to_sym]

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
