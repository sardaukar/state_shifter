state\_shifter
==============

This gem makes it easy to incorporate state machine behavior in a Ruby class.

Features include:

* on\_entry and on\_transition handlees
* ActiveRecord integration
* event guards and easy event handlers
* graphViz visualization creator
* flexible machine syntax

Usage
-----

An example of state machine definition possible with this gem:

```
class Simple
  include StateShifter::Definition

  state_machine do

    # first state to be defined is the initial one
    state :new do
      event :submit => :awaiting_review
    end

    state :awaiting_review do
      event :review => :being_reviewed
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
```

Basically, you need to include ```StateShifter::Definition``` and have a ```state_machine``` block. The initial state is the first one on the definition, and events are in the form of ```event event_name => next_state_name```. Events can have guards, and also refer back to the same state, in which case you simple omit the ```next_state_name``` - this is pointless without a ```:call``` option passed to it, as the next example shows.

```
class Advanced
  include StateShifter::Definition

  ###

  state_machine do

    state :initialized do

      event :start_date_changed, :call => :handle_start_date_changed
      event :forced_start => :running
      event :start_date_reached => :running, :if => :start_date_reached?
      event :abort_initialized_contest => :finalized
    end

    state :running do

      on_entry do |previous_state, trigger_event|
        running_entry previous_state, trigger_event
      end

      event :abort_running_contest => :notify_stakeholders
      event :deadline_reached => :notify_organizers, :if => :entries_deadline_reached?
      event :spots_filled  => :notify_organizers, :if => :spots_filled?
      event :deadline_reached_without_approvals  => :notify_pending_users, :if => :entries_deadline_reached_without_approvals?
      event :deadline_reached_without_entries => :finalized, :if => :entries_deadline_reached_without_entries?
    end

    state :notify_organizers do
      on_entry :send_notification_to_organizers
      event :organizers_notified => :awaiting_organizer_reply
    end

    state :awaiting_organizer_reply do
      event :organizer_confirmation_missing => :notify_stakeholders, :if => :organizer_confirmation_deadline_reached?
      event :organizer_confirmation_received => :notify_approved_users
      event :organizer_has_more_tickets  => :running
    end

    state :notify_stakeholders do
      on_entry :send_notification, :stakeholders, :organizers
      event :stakeholders_notified => :cancelled
    end

    state :cancelled

    state :notify_pending_users do
      on_entry :send_notification, :pending_users
      event :pending_users_notified => :finalized
    end

    state :notify_approved_users do
      on_entry :send_notification_to_approved_users
      event :approved_users_notified => :send_list_to_organizers
     end

    state :send_list_to_organizers do
      on_entry :send_guestlist_to_organizers
      event :list_sent_to_organizers => :awaiting_attendance
    end

    state :awaiting_attendance do
      event :remind_to_fill_in_report => :create_report_filling_requests
    end

    state :create_report_filling_requests do
      on_entry :send_report_filling_requests
      event :finalize => :finalized
    end

    state :finalized

    on_transition do |from,to,trigger_event, duration|
      benchmark from, to, trigger_event, duration
    end
  end

  ###

  def send_notification to
    #
  end

  def entries_deadline_reached?
    true
  end

  def running_entry previous_state, trigger_event
    #
  end

  def benchmark from, to, trigger_event, duration
    #
  end

end
```

Contributing to state\_shifter
------------------------------

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
---------

Copyright (c) 2012 Bruno Antunes. See LICENSE.txt for
further details.
