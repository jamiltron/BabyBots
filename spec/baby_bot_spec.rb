require 'spec_helper.rb'

$loading = BabyBots::State.new(:loading, {1 => :ready, :else => :loading})
$ready   = BabyBots::State.new(:ready,   {1 => :run, :else => :loading})
$run     = BabyBots::State.new(:run,     {:else => :run})
                               

TEST_MACHINE1 = { :loading => {1 => :ready, :else => :loading},
                                   :ready   => {1 => :run, :else => :loading},
                                   :run     => {:else => :run} }

class BB < BabyBots::BabyBot
  def initialize
    super
    build({ :loading => {1   => :ready, :else => :loading},
            :ready   => {"0" => :loading, "1" => :run, :else => :ready},
            :run     => {:else => :run}})
  end

  def pre_loading(event=nil)
    event.to_i
  end

  def post_loading(event=nil)
    event
  end

  def pre_ready(event=nil)
    event.to_s
  end

  def post_ready(event=nil)
    event
  end

  def post_run(event=nil)
    true
  end
end

class BB2 < BB
  def post_loading
    true
  end
end

class BB3 < BB
  def post_loading(event, stuff, mo_stuff)
    true
  end
end


describe BabyBots::BabyBot do
  it "should be able to be initiated with no additional initialization" do
    test = BabyBots::BabyBot.new
    test.states.should == {}
  end

  it "should be able to be initialized with a state table" do
    test = BabyBots::BabyBot.new(TEST_MACHINE1)
    test.states.should == {:loading => $loading, :ready => $ready, :run => $run}
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

  it "should be able to have states built using the build method" do
    test = BabyBots::BabyBot.new
    test.build(TEST_MACHINE1)
  end

  it "should allow states to be overwritten using build" do
    test = BabyBots::BabyBot.new(TEST_MACHINE1)
    test.build({ :loading => {1 => :run, 2 => :loading} })

    test2 = BabyBots::BabyBot.new({ :loading => {1 => :run, 2 => :loading},
                                   :ready   => {1 => :run, :else => :loading},
                                   :run     => {:else => :run} })
    test.states.should == test2.states
  end

  it "should run the example, with the starting state being loading" do
    test = BB.new
    test.start.state.should == :loading
  end

  it "should run the example, with the current state being loading" do
    test = BB.new
    test.state.should == :loading
  end

  it "should run the example, iterating from loading to ready on inputs 1" do
    test = BB.new
    test.process(1)
    test.state.should == :ready
  end

  it "should run the example, using pre_loading to convert \"1\" to 1" do
    test = BB.new
    test.process("1")
    test.state.should == :ready
  end

  it "should run the example, using pre_loading to convert \"1\" to 1" do
    test = BB.new
    test.process("1")
    test.state.should == :ready
  end

  it "should run the example, use pre_loading to convert \"1\" to 1, but use post_loading to return \"1\"" do
    test = BB.new
    final_var = test.process("1")
    test.state.should == :ready
    final_var.should == "1"
  end

  it "should run the example, and be able to be reset using the restart method" do
    test = BB.new
    test.process(1)
    test.state.should == :ready
    test.restart
    test.state.should == :loading
  end

  it "should run the example, where anything other than \"1\" or \"0\" looping in :ready" do
    test = BB.new
    test.process(1)
    test.state.should == :ready
    test.process("banana phone")
    test.state.should == :ready
    test.process(99)
    test.state.should == :ready
    test.process
    test.state.should == :ready
  end

  it "should run the example, lacking a pre_run should not have any ill side-effects" do
    test = BB.new
    test.process(1)
    test.process(1)
    ret1 = test.process("chocolate rain")
    ret2 = test.process("gournal")
    ret1.should == ret2
    ret2.should == true
  end

  it "should run the example, and not have issue with a zero-arity method" do
    test = BB2.new
    test.process(1)
    test.process(1)
    test.state.should == :run
  end

  it "should run the example, and raise an ArgumentError on arity error" do
    test = BB3.new
    lambda{ test.process(1)}.should raise_error ArgumentError
  end


end
