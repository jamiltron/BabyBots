require 'baby_bots'

class BB < BabyBots::BabyBot
  def initialize
    super
    build({ :loading => {1   => :ready, :else => :loading},
            :ready   => {"0" => :loading, "1" => :run, :else => :ready},
            :run     => {:else => :run}})
  end

  def pre_loading(event=nil)
    puts "In loading, converting event to an integer."
    event.to_i
  end

  def post_loading(event=nil)
    puts "Leaving loading, notice event is the supplied event, rather than the converted event in pre_loading."
    puts "event: #{event}"
    event
  end

  def pre_ready(event=nil)
    puts "In ready, converting event to a string."
    event.to_s
  end

  def post_ready
    puts "Leaving ready, notice no parameter is supplied."
  end

  def pre_run(event=nil)
    puts "Done! We'll loop here forever."
  end

  def post_run(event=nil)
    puts "Why not return true no matter what?"
    true
  end
end

bb = BB.new

puts "Current state should be loading."
puts "Current state: #{bb.state}"

puts "\nLet's go from loading to ready, we'll convert this event into an integer."
bb.process("1")

puts "\nLet's loop back to loading."
bb.process(0)

puts "\nLet's check that else is working."
bb.process("99")

puts "\nOk, let's go to run."
bb.process(1)
bb.process(1)

puts "\nLet's see if it returns true."
final_val = bb.process("anything")
puts "final_val: #{final_val}"
