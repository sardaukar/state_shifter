require_relative 'simple'

class Mounted
  include StateShifter::Mountable

  mount_state_machine Simple

end
