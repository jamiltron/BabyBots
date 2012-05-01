require 'spec_helper.rb'

$loading = BabyBots::State.new(:loading, {1 => :ready, :else => :loading})
$ready   = BabyBots::State.new(:ready,   {1 => :run, :else => :loading})
$run     = BabyBots::State.new(:run,     {:else => :run})
                               

TEST_MACHINE1 = { :loading => {1 => :ready, :else => :loading},
                                   :ready   => {1 => :run, :else => :loading},
                                   :run     => {:else => :run} }

describe BabyBots::BabyBot do
  it "should be able to be initiated with no additional initialization" do
    test = BabyBots::BabyBot.new
    test.states.should == {}
  end

  it "should be able to be initialized with a state table" do
    test = BabyBots::BabyBot.new(TEST_MACHINE1)
    test.states.should == TEST_MACHINE1
  end

  it "should have states be able to be added using add_state" do
    test = BabyBots::BabyBot.new
    test.add_state($loading)
    test.states.should == {:loading => $loading}
    test.add_state($ready)
    test.states.should == {:loading => $loading, :ready => $ready}
    test.add_state($run)
    test.states.should == {:loading => $loading, :ready => $ready, :run => $run}
  end
end
