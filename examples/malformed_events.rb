class MalformedEvents
  include StateShifter::Definition

  state_machine do 

    # first state to be defined is the initial one
    state :new do
      event :submit => :awaiting_review
    end

    state :awaiting_review do
      event :submit => :being_reviewed
    end

  end
  
end
