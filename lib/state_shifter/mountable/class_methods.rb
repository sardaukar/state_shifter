module StateShifter
  module Mountable
    module ClassMethods

      attr_accessor :mountable_class_name

      def mount_state_machine mountable_class_name
        self.mountable_class_name = mountable_class_name
      end

     end
  end
end
