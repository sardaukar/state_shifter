class MalformedPersistence
  include StateShifter::Definition

  ### 

  state_machine do

    state :initialized do

      event :start_date_changed, :call => :handle_start_date_changed
      event :forced_start => :running
      event :start_date_reached => :running, :if => :start_date_reached?
      event :abort_initialized_contest => :finalized
    end

  end

  persist_attribute :lollies

  ###

end
