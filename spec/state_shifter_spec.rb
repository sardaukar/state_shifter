require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require_relative '../examples/simple'
require_relative '../examples/advanced'

describe "StateShifter" do
    
  context 'Simple' do

    before(:each) do
      @simple = Simple.new
    end

    it 'should have all states and events defined' do
      @simple.state_names.should == [:new, :awaiting_review, :being_reviewed, :accepted, :rejected]
      @simple.event_names.should == [:submit, :review, :accept, :reject]
    end

    it 'should have the proper initial state set' do
      @simple.initial_state.should == :new
      @simple.current_state.should == :new
    end

    it 'should transit between states properly' do
      @simple.submit
      @simple.current_state.should == :awaiting_review

      @simple.review!
      @simple.current_state.should == :being_reviewed
    end

    it 'should know the current state' do
      @simple.new?.should be_true
      @simple.accepted?.should be_false

      @simple.submit

      @simple.awaiting_review?.should be_true
      @simple.new?.should be_false
    end

    it 'should respect guard statements' do
      @simple.submit
      @simple.review

      @simple.reject.should_not be_true
      lambda { @simple.reject!}.should raise_error(StateShifter::GuardNotSatisfied, 'bad_article?')

      @simple.accept.should be_true
      @simple.current_state.should == :accepted
    end

    it 'should know if a transition is possible' do
      @simple.can_submit?.should be_true

      @simple.submit

      @simple.can_review?.should be_true

      @simple.review

      @simple.can_accept?.should be_true
      @simple.can_reject?.should be_false
    end

    it 'should properly indicate next states' do
      @simple.next_states.should == [:awaiting_review]
      @simple.transitionable_states.should == [:awaiting_review]

      @simple.submit!
      @simple.next_states.should == [:being_reviewed]
      @simple.transitionable_states.should == [:being_reviewed]

      @simple.review!
      @simple.next_states.should == [:accepted, :rejected]
      @simple.transitionable_states.should == [:accepted]

      @simple.accept
      @simple.next_states.should == []
      @simple.transitionable_states.should == []
    end

    it 'should respect proper transition precedence' do
      @simple.current_state.should == :new
      lambda { @simple.review! }.should raise_error(StateShifter::TransitionHalted, 'you cannot transition from new via review')
    end

  end

  context 'Malformed' do

    it 'should complain about redifining states' do
      lambda { require_relative '../examples/malformed_states' }.should raise_error(StateShifter::RedifiningState, 'new')
    end

    it 'should complain about redifining events' do
      lambda { require_relative '../examples/malformed_events' }.should raise_error(StateShifter::RedifiningEvent, 'submit')
    end

    it 'should complain about undefined guards' do
      advanced = Advanced.new
      lambda { advanced.can_start_date_reached?}.should raise_error(StateShifter::GuardMethodUndefined, 'start_date_reached?')
    end

    it 'should complain about undefined callbacks on state entry' do
      advanced = Advanced.new
      advanced.forced_start!
      
      lambda { advanced.deadline_reached }.should raise_error(StateShifter::CallbackMethodNotDefined, 'send_notification_to_organizers')
    end

  end

  context 'Advanced' do

    before(:each) do
      @advanced = Advanced.new
    end

    it 'should complain about looping event callbacks not being defined' do
      lambda { @advanced.start_date_changed }.should raise_error(StateShifter::CallbackMethodNotDefined, 'handle_start_date_changed')
    end

    it 'should call looping event callbacks' do
      @advanced.stub!(:handle_start_date_changed)
      
      @advanced.should_receive(:handle_start_date_changed)
      @advanced.start_date_changed
    end

    it 'state on_entry callbacks should work' do
      # block
      @advanced.should_receive(:running_entry).with(:initialized, :forced_start).and_return(nil)
      @advanced.forced_start

      # method name only
      @advanced.should_receive(:send_notification_to_organizers)
      @advanced.deadline_reached!
    end

    it 'the on_transition callback should work' do
      @advanced.should_receive(:benchmark).with(:initialized, :running, :forced_start!, an_instance_of(Float)).and_return(nil)
      @advanced.forced_start!
    end

  end
end
