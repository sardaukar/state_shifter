module StateShifter
  module Definition

    def self.included klass
      klass.send :include, InstanceMethods
      klass.extend ClassMethods
    end

  end
end
