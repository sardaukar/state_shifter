require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require_relative '../examples/simple'
require_relative '../examples/advanced'
require_relative '../examples/mounted'

shared_examples_for 'a simple state machine' do
  
  before(:each) do
    @state_machine = described_class.new
  end

  it 'should have all states and events defined' do
    @state_machine.state_names.should == [:new, :awaiting_review, :being_reviewed, :accepted, :rejected]
    @state_machine.event_names.should == [:submit, :review, :accept, :reject]
  end

  it 'should have the proper initial state set' do
    @state_machine.initial_state.should == :new
    @state_machine.current_state.should == :new

    @state_machine.submit
    @state_machine.initial_state.should == :new
    @state_machine.current_state.should == :awaiting_review
  end

  it 'should transit between states properly' do
    @state_machine.current_state.should == :new
    @state_machine.submit
    @state_machine.current_state.should == :awaiting_review

    @state_machine.review!
    @state_machine.current_state.should == :being_reviewed
  end

  it 'should know the current state' do
    @state_machine.current_state.should == :new

    @state_machine.new?.should be_true
    @state_machine.accepted?.should be_false

    @state_machine.submit

    @state_machine.awaiting_review?.should be_true
    @state_machine.new?.should be_false
  end

  it 'should respect guard statements' do
    @state_machine.current_state.should == :new
    @state_machine.submit
    @state_machine.review

    @state_machine.reject.should_not be_true
    lambda { @state_machine.reject!}.should raise_error(StateShifter::GuardNotSatisfied, 'bad_article?')

    @state_machine.accept.should be_true
    @state_machine.current_state.should == :accepted
  end

  it 'should know if a transition is possible' do
    @state_machine.current_state.should == :new
    @state_machine.can_submit?.should be_true

    @state_machine.submit

    @state_machine.can_review?.should be_true

    @state_machine.review

    @state_machine.can_accept?.should be_true
    @state_machine.can_reject?.should be_false
  end

  it 'should properly indicate next states' do
    @state_machine.current_state.should == :new
    @state_machine.next_states.should == [:awaiting_review]
    @state_machine.transitionable_states.should == [:awaiting_review]

    @state_machine.submit!
    @state_machine.next_states.should == [:being_reviewed]
    @state_machine.transitionable_states.should == [:being_reviewed]

    @state_machine.review!
    @state_machine.next_states.should == [:accepted, :rejected]
    @state_machine.transitionable_states.should == [:accepted]

    @state_machine.accept
    @state_machine.next_states.should == []
    @state_machine.transitionable_states.should == []
  end

  it 'should respect proper transition precedence' do
    @state_machine.current_state.should == :new
    lambda { @state_machine.review! }.should raise_error(StateShifter::TransitionHalted, 'you cannot transition from new via review')
  end

end

describe Simple do
   
  it_should_behave_like 'a simple state machine'

end

describe Mounted do

  it_should_behave_like 'a simple state machine'

end

describe 'Malformed state machines' do

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

describe 'Advanced state machine functionality' do

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

