class Review < ActiveRecord::Base
  include StateShifter::Definition

  state_machine do

    # first state to be defined is the initial one
    state :new do
      tags :reviewable
      event :submit => :awaiting_review
    end

    state :awaiting_review do
      tags :reviewable, :processing
      event :review => :being_reviewed
    end

    state :being_reviewed do
      tags :reviewable, :processing
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
