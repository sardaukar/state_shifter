module StateShifter
  module Definition

    def self.included klass
      klass.send :include, InstanceMethods
      klass.extend ClassMethods

      if Object.const_defined?(:ActiveRecord)
        if klass < ActiveRecord::Base
          klass.send :include, ActiveRecordIntegrationMethods
          klass.before_validation :write_initial_state
        end
      end
    end

  end
end
