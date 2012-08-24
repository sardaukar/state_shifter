require 'state_shifter/state'
require 'state_shifter/event'
require 'state_shifter/definition'
require 'state_shifter/definition/contents'
require 'state_shifter/definition/class_methods'
require 'state_shifter/definition/instance_methods'
require 'state_shifter/mountable'
require 'state_shifter/mountable/class_methods'
require 'state_shifter/mountable/instance_methods'

class ::StateShifter::TransitionHalted < Exception ; end
class ::StateShifter::GuardMethodUndefined < Exception ; end
class ::StateShifter::GuardNotSatisfied < Exception ; end
class ::StateShifter::CallbackMethodNotDefined < Exception ; end
class ::StateShifter::RedifiningEvent < Exception ; end
class ::StateShifter::RedifiningState < Exception ; end

