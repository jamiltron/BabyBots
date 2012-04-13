module BabyBots

  class State 
    attr_accessor :state, :table
    
    def initialize(state, table={})
      @state = state
      @table = table
    end

    def add_transition(event, transition, &callback)
      @table[event] = [transition, callback]
    end
  end

end
