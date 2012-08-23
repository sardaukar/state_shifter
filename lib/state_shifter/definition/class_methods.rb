module StateShifter
  module Definition
    module ClassMethods

      attr_accessor :state_machine_definition

      def state_machine &definition
        @state_machine_definition = Contents.new(&definition)
        add_methods
      end

      def add_methods
        @state_machine_definition.states.each do |state_name, state_definition|
          
          module_eval do

            define_method "_next_states" do |from_state, *options|
              options = options.first || {}
              next_states_hash   = {}
              check_guards  = options.has_key?(:check_guards)

              self.class.state_machine_definition.states[from_state.to_sym].events.each do |event_name, event_def|
                if event_def.has_guards? && check_guards
                  next if @subject.send(:check_guards, event_name).is_a?(Array)
                end

                next_states_hash.merge!( event_def.to.nil? ? { from_state.to_sym => event_name } : { event_def.to => event_def.name } )
              end

              next_states_hash.keys.uniq.sort
            end

            define_method "#{state_name}?" do
              current_state == state_name
            end

            state_definition.events.each do |event_name, event_definition|

              define_method "can_#{event_name}?" do
              
                this_event = self.class.state_machine_definition.events[event_name.to_sym]
                
                current_state == this_event.from && !check_guards(event_name).is_a?(Array) 
              
              end

              define_method "#{event_name}!" do

                self.send event_name.to_sym, true
              
              end

              define_method "#{event_name}" do |bang=false|

                if current_state != event_definition.from
                  if bang  
                    halt("you cannot transition from #{current_state} via #{event_name}")
                  else
                    return false
                  end
                end
                
                if (failed_guards = check_guards(event_name)).is_a?(Array)
                  if bang
                    failed_guards.delete_at(0)
                    raise ::StateShifter::GuardNotSatisfied, "#{failed_guards.join}"
                  else 
                    return false
                  end
                end

                transition :to => ( event_definition.to.nil? ? current_state : event_definition.to ), :trigger => ( bang ? "#{event_name}!" : event_name )
               
              end

            end

          end
        end
      end

    end
  end
end
