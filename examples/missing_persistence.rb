class MissingPersistence < ActiveRecord::Base
  include StateShifter::Definition

  ### 

  persist_attribute :lollies

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
      event :changed_properties
      event :keep_users_engaged
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
      event :keep_organizers_engaged
      event :organizer_confirmation_received => :notify_approved_users
      event :organizer_has_more_tickets  => :running
    end

    state :notify_stakeholders do
      on_entry :send_notification_to_stakeholders
      event :stakeholders_notified => :cancelled
    end

    state :cancelled

    state :notify_pending_users do
      on_entry :send_notification_to_pending_users
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
