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

    state :being_reviewed do
      event :accept => :accepted, :if => :cool_article?
      event :reject => :rejected, :if => :bad_article?
    end

    state :accepted
    state :rejected

  end

  def cool_article?
    true
  end

  def bad_article?
    false
  end

end
