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

    # add a new state to the state machine
    def add_state(state, start=nil)
      # key on state names to the actual state hash
      @states[state.state] = state
      if start
        @start = state
        @curr = @start
      end
    end


    # accepts a hash of hashes consiting of {state => {event => transition, ...} ...}
    # structure, and adds these states to the state machine, assumes first state
    # is the starting state
    def build(table)
      first_state = true
      
      # iterate through the provided {state => {event => transition, ...}, ...}
      table.each do |state, state_table|
        temp_state = State.new(state)
        
        # iterate through each event and transition, building up the transitions
        state_table.each do |event, transition|
          temp_state.add_transition(event, transition)
        end

        # finally, add the state to the machine, and since we've already
        # added a start state, clear the first_state flag
        add_state(temp_state, first_state)
        first_state = false
      end
    end

    def state
      @curr.state
    end

    # this is the driving function behind the fsa, process
    # will check the current state, doing any processing necessary
    # on the input based on whether or not this 
    def process(event=nil)
      # get the current state
      curr_state = @curr

      # check if we need to preprocess the event
      if respond_to?("pre_#{@curr.state}")
        cooked_event = send("pre_#{@curr.state}", event)
      end

      if cooked_event
        next_state = @states[curr.table[cooked_event]]
      else
        next_state = @states[curr.table[event]]
      end

      if next_state.nil?
        next_state = @states[curr.table[:else]]
      end
      
      # if the event is nil, and there is no :else clause,
      # throw an exception
      if next_state.nil?
        raise NoSuchTransitionException,
        "No valid transition #{event} for #{@curr.state}"
      end

      # check if we need to postprocess the event, this will act
      # as the "return" from any state transition (even self-looping transitions)
      if respond_to?("post_#{@curr.state}")
        ret_val = send("post_#{@curr.state}", event)
      elsif respond_to?("post_cooked_#{curr.state}")
        ret_val = send("post_#{@curr.state}", cooked_event)
      end
      

      # actually transition, and make sure such a transition exists
      @curr = next_state
      if @curr.nil?
        raise NoSuchStateException,
        "No valid state #{@curr} for transition #{event} from #{curr_state}"
      end

      return ret_val
    end

    def restart
      @curr = @start
    end
  end

end
