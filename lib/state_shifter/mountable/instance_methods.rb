module StateShifter
  module Mountable
    module InstanceMethods

      attr_accessor :state_machine_definition

      def initialize
        @state_machine_definition = self.class.mountable_class_name.new
        @state_machine_definition.instance_variable_set(:@subject,self)

        ( @state_machine_definition.methods - Object.methods).sort.each do |meth|
          self.class.send :define_method, meth, &@state_machine_definition.method(meth)
        end

        super
      end

    end
  end
end
