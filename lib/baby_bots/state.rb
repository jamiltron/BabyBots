module BabyBots

  class State 
    attr_reader :state, :table
    
    def initialize(state, table={})
      @state = state
      @table = table
    end

    def add_transition(event, transition, &callback)
      @table[event] = transition
    end

    # the idea behind build is that you can call multiple
    # :event :transition and the build method
    # will parse them out and add them to state
    def build(*args)
      args.map {|k,v| add_transition(k, v) }
    end
  end
end
