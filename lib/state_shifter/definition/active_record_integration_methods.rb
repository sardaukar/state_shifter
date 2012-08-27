module StateShifter
  module Definition
    module ActiveRecordIntegrationMethods

      class ::StateShifter::Definition::StatePersistenceAttributeNotPresent < RuntimeError; end 

      def check_attr_presence
        raise StatePersistenceAttributeNotPresent unless self.attribute_names.include? self.class.persist_attr_name.to_s
      end

      def get_current_state
        check_attr_presence
        read_attribute self.class.persist_attr_name
      end

      def set_current_state value
        check_attr_presence
        update_attribute self.class.persist_attr_name, value
      end

      def write_initial_state
        check_attr_presence
        write_attribute self.class.persist_attr_name, self.class.state_machine_definition.initial_state.name.to_sym
      end

    end
  end
end
