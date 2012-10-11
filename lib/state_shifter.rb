require 'state_shifter/state'
require 'state_shifter/event'
require 'state_shifter/definition'
require 'state_shifter/definition/contents'
require 'state_shifter/definition/class_methods'
require 'state_shifter/definition/instance_methods'
require 'state_shifter/definition/active_record_integration_methods'
require 'state_shifter/draw'

require 'state_shifter/railtie' if defined?(Rails)

module StateShifter

  class TransitionHalted < Exception ; end
  class GuardMethodUndefined < Exception ; end
  class GuardNotSatisfied < Exception ; end
  class CallbackMethodNotDefined < Exception ; end
  class RedifiningEvent < Exception ; end
  class RedifiningState < Exception ; end
  class PersistenceAttributeAlreadyDefined < Exception ; end

end
