module StateShifter
  module Mountable
    module ClassMethods

      attr_accessor :state_machine_definition

      def mount_state_machine mountable_class_name
        self.state_machine_definition = mountable_class_name.new
        self.state_machine_definition.subject = self
        #self.state_machine_definition.propagate_events_from_definition_to_subject
      end

     end
  end
end
