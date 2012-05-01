require 'spec_helper.rb'

TEST_NAME     = :test
TEST_TRANS1_1 = {0 => :test}
TEST_TRANS1_2 = {1 => :done}
TEST_TRANS1_3 = {:else => :test}
TEST_TABLE1   = TEST_TRANS1_1.merge TEST_TRANS1_2.merge TEST_TRANS1_3
TEST_TABLE2   = {2 => :two, 3 => :three}


describe BabyBots::State do
  it "should require a state name" do
    test = BabyBots::State.new(TEST_NAME)
    test.state.should == TEST_NAME
  end

  it "should provide an empty transition table if none is supplied" do
    test = BabyBots::State.new(TEST_NAME)
    test.state.should == TEST_NAME
    test.table.should == {}
  end

  it "should accept a state name and transition table" do
    test = BabyBots::State.new(TEST_NAME, TEST_TABLE1)
    test.state.should == TEST_NAME
    test.table.should == TEST_TABLE1
  end

  it "should be able to have its transition table built after construction" do
    test = BabyBots::State.new(TEST_NAME)
    test.table.should == {}
    test.build(TEST_TABLE1)
    test.table.should == TEST_TABLE1
  end

  it "should merge changes between uses of build" do
    test = BabyBots::State.new(TEST_NAME, TEST_TABLE2)
    test.table.should == TEST_TABLE2
    test.build(TEST_TABLE1)
    test.table.should == TEST_TABLE2.merge(TEST_TABLE1)
  end
    
  it "should allow transitions to be added piece-by-piece via add_transition" do
    test = BabyBots::State.new(TEST_NAME)
    test.table.should == {}
    test.add_transition(0, :test)
    test.table.should == {0 => :test}
    test.add_transition(1, :done)
    test.table.should == {0 => :test, 1 => :done}
    test.add_transition(:else, :test)
    test.table.should == TEST_TABLE1
  end
  
  it "should allow transitions to be overwritten using add_transition" do
    test = BabyBots::State.new(TEST_NAME, TEST_TABLE1)
    test.table.should == TEST_TABLE1
    test.add_transition(:else, :error)
    test.table.should == TEST_TRANS1_1.merge(TEST_TRANS1_2.merge({:else => :error}))
  end
  
  it "should allow transitions to be overwritten using build" do
    test = BabyBots::State.new(TEST_NAME, TEST_TABLE1)
    test.build({:else => :error})
    test.table.should == TEST_TRANS1_1.merge(TEST_TRANS1_2.merge({:else => :error}))
  end

  it "should allow transitions to be removed using remove_transition" do
    test = BabyBots::State.new(TEST_NAME, TEST_TABLE1)
    test.remove_transition(:else)
    test.table.should == TEST_TRANS1_1.merge(TEST_TRANS1_2)
  end

  it "should allow transitions to be deleted by setting their transition to NOWHERE" do
    test = BabyBots::State.new(TEST_NAME, TEST_TABLE1)
    test.add_transition(:else, BabyBots::NOWHERE)
    test.table.should == TEST_TRANS1_1.merge(TEST_TRANS1_2)
    test.build({0 => BabyBots::NOWHERE, 1 => BabyBots::NOWHERE})
    test.table.should == {}
  end
end
