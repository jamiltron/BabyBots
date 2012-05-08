module BabyBots
  # Transition state used to remove events from a transition table.
  NOWHERE = :nowhere__

  # Defualt Error Transition
  ERR     = :err__

  # The state contained within the BabyBots Finite State Automata.
  # States have an event that transitions to a new state. They may also
  # have an event named :else which will be the transition used by the
  # containing BabyBot when calculating transitions where no such supplied
  # events exist.
  class State 
    attr_reader :state, :table
    
    # Sets the state name, as well as an optionally supplied transition table.
    def initialize(state, table={})
      # state name
      @state = state
      
      # transition table
      @table = table
    end

    # Adds a transition to the transition table. Table format is 
    # event => transition, where event is the "input" into the state.
    # Transitions are allowed to be deleted by being set to NOWHERE.
    def add_transition(event, transition)
      if transition == NOWHERE
        remove_transition(event)
      else
        @table[event] = transition
      end
    end

    # Provided a table, merge the state's current transition table
    # with the supplied one. Note that since this is part of a 
    # finite state machine, supplying events that already exist
    # in the transition table override this transition.
    def build(table)
      table.each { |k,v| add_transition(k, v) }
    end


    # Delete an entry from the transition table.
    def remove_transition(event)
      @table.delete(event)
    end
    
    # Equality is based on the same transition table.
    def ==(another_state)
      if @table == another_state.table then return true else return false end
    end
  end

  ERRSTATE = State.new(:err__)

end
