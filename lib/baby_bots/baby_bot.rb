module BabyBots

  class NoSuchStateException < Exception
  end

  class NoSuchTransitionException < Exception
  end

  class BabyBot
    attr_accessor :curr, :states, :start

    def initialize(states={})
      @states = states
      @start = nil
      @curr = nil
    end

    def add_state(state, start=nil)
      @states[state.state] = state.table
      if start
        @start = state.state
        @curr = @start
      end
    end

    def start
      @start.key
    end

    def process(event, *args)
      curr_state = @states[@curr]
      next_state = curr_state[event]
      
      if next_state.nil?
        raise NoSuchTransitionException,
        "No valid transition #{event} for #{@curr}"
      end

      @curr = next_state[0]
      if @curr.nil?
        raise NoSuchStateException,
        "No valid state #{@curr} for transition #{event} from #{curr_state}"
      end

      if next_state[1] then next_state[1].call(*args) end
    end
  end

end
