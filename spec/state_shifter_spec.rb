require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require_relative '../examples/simple'
require_relative '../examples/advanced'
require_relative '../examples/review'
require_relative '../examples/review_custom_persistence'

shared_examples_for 'a simple state machine' do

  before(:each) do
    @state_machine = described_class.new
    @state_machine.save if @state_machine.class < ActiveRecord::Base
  end

  it 'should have all states and events defined' do
    @state_machine.state_names.should == [:new, :awaiting_review, :being_reviewed, :accepted, :rejected]
    @state_machine.event_names.should == [:submit, :review, :accept, :reject]
  end

  it 'should have the proper initial state set' do
    @state_machine.initial_state.should == :new
    @state_machine.current_state.should == :new

    @state_machine.current_state_def.initial?.should be_true

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

    @state_machine.current_state_def.final?.should be_false

    @state_machine.submit!
    @state_machine.next_states.should == [:being_reviewed]
    @state_machine.transitionable_states.should == [:being_reviewed]

    @state_machine.review!
    @state_machine.next_states.should == [:accepted, :rejected]
    @state_machine.transitionable_states.should == [:accepted]

    @state_machine.accept
    @state_machine.next_states.should == []
    @state_machine.transitionable_states.should == []

    @state_machine.current_state_def.final?.should be_true
  end

  it 'should respect proper transition precedence' do
    @state_machine.current_state.should == :new
    lambda { @state_machine.review! }.should raise_error(StateShifter::TransitionHalted, 'you cannot transition from new via review')
  end

end

describe Simple do

  it_should_behave_like 'a simple state machine'

end

describe 'Malformed state machines' do

  it 'should complain about redifining states' do
    lambda { require_relative '../examples/malformed_states' }.should raise_error(StateShifter::RedifiningState, 'new')
  end

  it 'should complain about redifining events' do
    lambda { require_relative '../examples/malformed_events' }.should raise_error(StateShifter::RedifiningEvent, 'submit')
  end

  it 'should complain when the persistence attribute is set after the state machine definition' do
    lambda { require_relative '../examples/malformed_persistence' }.should raise_error(StateShifter::PersistenceAttributeAlreadyDefined)
  end

end

describe 'Advanced state machine functionality' do

  before(:each) do
    @advanced = Advanced.new
  end

  it 'should complain about undefined guards' do
    lambda { @advanced.can_start_date_reached?}.should raise_error(StateShifter::GuardMethodUndefined, 'start_date_reached?')
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
    @advanced.should_receive(:send_notification_to_organizers).with(no_args())
    @advanced.deadline_reached!
  end

  it 'state on_entry callbacks with an argument should work' do
    @advanced.forced_start
    @advanced.stub!(:entries_deadline_reached_without_approvals?).and_return(true)

    # method name only with args
    @advanced.should_receive(:send_notification).with(:pending_users)
    @advanced.deadline_reached_without_approvals!
  end

  it 'state on_entry callbacks with an array of arguments should work' do
    @advanced.forced_start

    # method name only with args
    @advanced.should_receive(:send_notification).with([:stakeholders, :organizers])
    @advanced.abort_running_contest!
  end

  it 'the on_transition callback should work' do
    @advanced.should_receive(:benchmark).with(:initialized, :running, :forced_start!, an_instance_of(Float)).and_return(nil)
    @advanced.forced_start!
  end

  it 'the on_transition callback should work in the proper order' do
    @advanced.should_receive(:benchmark).ordered.with(:initialized, :preparing, :event_associated!, an_instance_of(Float)).and_return(nil)
    @advanced.should_receive(:benchmark).ordered.with(:preparing, :running, :all_done!, an_instance_of(Float)).and_return(nil)
    @advanced.event_associated!
  end

end

describe Review do

  before(:all) do
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'

    ActiveRecord::Schema.define do
      create_table :reviews do |t|
        t.string    :current_state
      end
    end
  end

  after(:each) do
    described_class.destroy_all
  end

  it_should_behave_like 'a simple state machine'

  it "should tolerate strings as state names" do
    state_machine = described_class.new
    state_machine.save

    state_machine.current_state.should == :new
    state_machine.update_attribute(:current_state, "new")

    state_machine.new?.should be_true

    state_machine.submit
    state_machine.initial_state.should == :new

    state_machine.current_state.should == :awaiting_review
  end

  it "should have tag methods" do
    described_class.reviewable_states.should eq([:new, :awaiting_review, :being_reviewed])

    state_machine = described_class.new
    state_machine.save

    state_machine.reviewable?.should be_true
    state_machine.processing?.should be_false

    state_machine.submit
    state_machine.reviewable?.should be_true
    state_machine.processing?.should be_true

    state_machine.review!
    state_machine.reviewable?.should be_true
    state_machine.processing?.should be_true

    state_machine.accept!
    state_machine.reviewable?.should be_false
    state_machine.processing?.should be_false
  end

  it "should have state scopes" do
    state_machine = described_class.new
    state_machine.save
    state_machine.submit

    described_class.awaiting_review.size.should eq(1)
    described_class.reviewable.size.should eq(1)
  end

end

describe ReviewCustomPersistence do

  before(:all) do
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'

    ActiveRecord::Schema.define do
      create_table :review_custom_persistences do |t|
        t.string    :stamp
      end
    end
  end

  it_should_behave_like 'a simple state machine'

  it "should tolerate strings as state names" do
    state_machine = described_class.new
    state_machine.save

    state_machine.current_state.should == :new
    state_machine.update_attribute(:stamp, "new")

    state_machine.new?.should be_true

    state_machine.submit
    state_machine.initial_state.should == :new

    state_machine.current_state.should == :awaiting_review
  end

end

describe 'Malformed persistence definition' do

  before(:all) do
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'

    ActiveRecord::Schema.define do
      create_table :missing_persistences do |t|
        t.string    :xyz
      end
    end
  end

  it 'should complain when the persist attribute is not present' do
    require_relative '../examples/missing_persistence'
    review_custom_persistence = MissingPersistence.new
    lambda { review_custom_persistence.save }.should raise_error(StateShifter::Definition::StatePersistenceAttributeNotPresent)
  end

end
