module StateShifter
  module Definition
    module ActiveRecordIntegrationMethods

      class ::StateShifter::Definition::StatePersistenceAttributeNotPresent < RuntimeError; end

      def self.include_state_scopes(base)
        base.state_machine_definition.states.each do |name, definition|
          base.class_eval do
            scope name, -> { where(persist_attr_name => name) } unless respond_to?(name)
          end
        end

        base.state_machine_definition.state_tags.each do |name, states|
          base.class_eval do
            scope name, -> { where(persist_attr_name => states) } unless respond_to?(name)
          end
        end
      end

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
        raise StatePersistenceAttributeNotPresent unless self.attribute_names.include?(self.class.persist_attr_name.to_s)
        write_attribute self.class.persist_attr_name, self.class.state_machine_definition.initial_state.name.to_sym
      end

    end
  end
end
