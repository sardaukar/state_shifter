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
    expect(@state_machine.state_names).to eq [:new, :awaiting_review, :being_reviewed, :accepted, :rejected]
    expect(@state_machine.event_names).to eq [:submit, :review, :accept, :reject]
  end

  it 'should have the proper initial state set' do
    expect(@state_machine.initial_state).to eq :new
    expect(@state_machine.current_state).to eq :new

    expect(@state_machine.current_state_def.initial?).to be_truthy

    @state_machine.submit
    expect(@state_machine.initial_state).to eq :new

    expect(@state_machine.current_state).to eq :awaiting_review
  end

  it 'should transit between states properly' do
    expect(@state_machine.current_state).to eq :new
    @state_machine.submit
    expect(@state_machine.current_state).to eq :awaiting_review

    @state_machine.review!
    expect(@state_machine.current_state).to eq :being_reviewed
  end

  it 'should know the current state' do
    expect(@state_machine.current_state).to eq :new

    expect(@state_machine.new?).to be_truthy
    expect(@state_machine.accepted?).to be_falsey

    @state_machine.submit

    expect(@state_machine.awaiting_review?).to be_truthy
    expect(@state_machine.new?).to be_falsey
  end

  it 'should respect guard statements' do
    expect(@state_machine.current_state).to eq :new
    @state_machine.submit
    @state_machine.review

    expect(@state_machine.reject).to_not be_truthy
    expect(lambda { @state_machine.reject!}).to raise_error(StateShifter::GuardNotSatisfied, 'bad_article?')

    expect(@state_machine.accept).to be_truthy
    expect(@state_machine.current_state).to eq :accepted
  end

  it 'should know if a transition is possible' do
    expect(@state_machine.current_state).to eq :new
    expect(@state_machine.can_submit?).to be_truthy

    @state_machine.submit

    expect(@state_machine.can_review?).to be_truthy

    @state_machine.review

    expect(@state_machine.can_accept?).to be_truthy
    expect(@state_machine.can_reject?).to be_falsey
  end

  it 'should properly indicate next states' do
    expect(@state_machine.current_state).to eq :new
    expect(@state_machine.next_states).to eq [:awaiting_review]
    expect(@state_machine.transitionable_states).to eq [:awaiting_review]

    expect(@state_machine.current_state_def.final?).to be_falsey

    @state_machine.submit!
    expect(@state_machine.next_states).to eq [:being_reviewed]
    expect(@state_machine.transitionable_states).to eq [:being_reviewed]

    @state_machine.review!
    expect(@state_machine.next_states).to eq [:accepted, :rejected]
    expect(@state_machine.transitionable_states).to eq [:accepted]

    @state_machine.accept
    expect(@state_machine.next_states).to eq []
    expect(@state_machine.transitionable_states).to eq []

    expect(@state_machine.current_state_def.final?).to be_truthy
  end

  it 'should respect proper transition precedence' do
    expect(@state_machine.current_state).to eq :new
    expect(lambda { @state_machine.review! }).to raise_error(StateShifter::TransitionHalted, 'you cannot transition from new via review')
  end

end

describe Simple do

  it_should_behave_like 'a simple state machine'

end

describe 'Malformed state machines' do

  it 'should complain about redifining states' do
    expect(lambda { require_relative '../examples/malformed_states' }).to raise_error(StateShifter::RedifiningState, 'new')
  end

  it 'should complain about redifining events' do
    expect(lambda { require_relative '../examples/malformed_events' }).to raise_error(StateShifter::RedifiningEvent, 'submit')
  end

  it 'should complain when the persistence attribute is set after the state machine definition' do
    expect(lambda { require_relative '../examples/malformed_persistence' }).to raise_error(StateShifter::PersistenceAttributeAlreadyDefined)
  end

end

describe 'Advanced state machine functionality' do

  before(:each) do
    @advanced = Advanced.new
  end

  it 'should complain about undefined guards' do
    expect(lambda { @advanced.can_start_date_reached?}).to raise_error(StateShifter::GuardMethodUndefined, 'start_date_reached?')
  end

  it 'should call looping event callbacks' do
    expect(@advanced).to receive(:handle_start_date_changed)
    @advanced.start_date_changed
  end

  it 'state on_entry callbacks should work' do
    # block
    expect(@advanced).to receive(:running_entry).with(:initialized, :forced_start).and_return(nil)
    @advanced.forced_start

    # method name only
    expect(@advanced).to receive(:send_notification_to_organizers).with(no_args())
    @advanced.deadline_reached!
  end

  it 'state on_entry callbacks with an argument should work' do
    @advanced.forced_start
    allow(@advanced).to receive(:entries_deadline_reached_without_approvals?).and_return(true)

    # method name only with args
    expect(@advanced).to receive(:send_notification).with(:pending_users)
    @advanced.deadline_reached_without_approvals!
  end

  it 'state on_entry callbacks with an array of arguments should work' do
    @advanced.forced_start

    # method name only with args
    expect(@advanced).to receive(:send_notification).with([:stakeholders, :organizers])
    @advanced.abort_running_contest!
  end

  it 'the on_transition callback should work' do
    expect(@advanced).to receive(:benchmark).with(:initialized, :running, :forced_start!, an_instance_of(Float)).and_return(nil)
    @advanced.forced_start!
  end

  it 'the on_transition callback should work in the proper order' do
    expect(@advanced).to receive(:benchmark).ordered.with(:initialized, :preparing, :event_associated!, an_instance_of(Float)).and_return(nil)
    expect(@advanced).to receive(:benchmark).ordered.with(:preparing, :running, :all_done!, an_instance_of(Float)).and_return(nil)
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

    expect(state_machine.current_state).to eq :new
    state_machine.update_attribute(:current_state, "new")

    expect(state_machine.new?).to be_truthy

    state_machine.submit
    expect(state_machine.initial_state).to eq :new

    expect(state_machine.current_state).to eq :awaiting_review
  end

  it "should have tag methods" do
    expect(described_class.reviewable_states).to eq([:new, :awaiting_review, :being_reviewed])

    state_machine = described_class.new
    state_machine.save

    expect(state_machine.reviewable?).to be_truthy
    expect(state_machine.processing?).to be_falsey

    state_machine.submit
    expect(state_machine.reviewable?).to be_truthy
    expect(state_machine.processing?).to be_truthy

    state_machine.review!
    expect(state_machine.reviewable?).to be_truthy
    expect(state_machine.processing?).to be_truthy

    state_machine.accept!
    expect(state_machine.reviewable?).to be_falsey
    expect(state_machine.processing?).to be_falsey
  end

  it "should have state scopes" do
    state_machine = described_class.new
    state_machine.save
    state_machine.submit

    expect(described_class.awaiting_review.size).to eq(1)
    expect(described_class.reviewable.size).to eq(1)
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

    expect(state_machine.current_state).to eq :new
    state_machine.update_attribute(:stamp, "new")

    expect(state_machine.new?).to be_truthy

    state_machine.submit
    expect(state_machine.initial_state).to eq :new

    expect(state_machine.current_state).to eq :awaiting_review
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
    expect(lambda { review_custom_persistence.save }).to raise_error(StateShifter::Definition::StatePersistenceAttributeNotPresent)
  end

end
