module BabyBots
  
  # Error to handle attempts to transition to a state that does not exist.
  class NoSuchStateException < Exception
  end

  # Error to handle attempts to use a transition that does not exist.
  class NoSuchTransitionException < Exception
  end

  # A tiny finite-state automata class.
  class BabyBot
    attr_accessor :curr, :start

    # Accepts an optional hash of states.
    def initialize(states={})
      # Hash of state names to state objects
      @states = {}
      if !states.empty? then build states end

      # Add our default error state to provide user-based 'error' handling.
      add_state(ERRSTATE)
      
      # Initial state
      @start = nil
      # Current state
      @curr = nil
    end
    
    # Provides the states, minus the default error state (because it isn't
    # really a state in the true sense). Note that this is NOT a reference
    # to the BabyBot's actual states, but rather a duplicate.
    def states
      new_states = @states.dup
      new_states.delete(ERR)
      return new_states
    end

    # Adds a new state to the finite-state automata, also accepts
    # an optional start flag, which will set the supplied state as the initial
    # state. Note that this machine may only have one start state. Additionally,
    # adding the first start state will set @curr to be this state, after this
    # has been done @curr will remain on whatever state it is currently residing
    # on, and must be reset using the restart method.
    def add_state(state, start=nil)
      # key on state names to the actual state object
      @states[state.state] = state

      # if this is a start state
      if start
        @start = state

        # only set the current state to the start state if @curr is nil.
        if @curr.nil? then @curr = @start end
      end
    end

    # Since we implement a default error state, this empty will check
    # if there are any other states aside from that one.
    def empty?
      @states.keys.find_all { |k| k != ERR }.empty?
    end

    # Build up this machine's states with a given state table. The format of
    # this table is assumed to be {state_name => {event1 => transition1, ...}}.
    # build assumes that the first state provided is the start state, although
    # the optional no_first parameter may be set to override this.
    def build(table, no_first=false)
      first_state = !no_first

      # iterate through each provided state table entries
      table.each do |state, state_table|
        temp_state = State.new(state)

        # iterate through the current state table, adding events => transition
        state_table.each do |event, transition|
          temp_state.add_transition(event, transition)
        end

        # finally, add the state to the machine, and since we've already
        # added a start state, clear the first_state flag
        add_state(temp_state, first_state)
        first_state = false
      end
    end

    # Return the current state's actual state.
    def state
      @curr.state
    end

    # Return the name of the current state
    def state_name
      @curr.state.state
    end

    # Process the finite state automata with the given event.
    # This will first see if the finite state automata has a defined method
    # named "pre_{current_state}", and if so "cook" the input event with this
    # method. Process will then use the cooked input if available, or the raw
    # input if there is none to compute the transition. Before actually 
    # transitioning, it will then send the raw output to a method of
    # "post_{current_state}", which will be the return value. If a method named
    # "post_cook_{current_state}" is supplied, it will send the cooked event to
    # this method instead of using "post_{current_state}".
    def process(event=nil)
      # get the current state
      curr_state = @curr

      # check if we need to preprocess the event
      if respond_to?("pre_#{@curr.state}")
        cooked_event = my_send("pre_#{@curr.state}", event)
      end

      # calculate the next state
      if !cooked_event.nil?
        next_state = @states[curr.table[cooked_event]]
      else
        next_state = @states[curr.table[event]]
      end

      # if there is no such transition, see if there is an a translation
      # known as else, and use that as the next state
      if next_state.nil?
        next_state = @states[curr.table[:else]]
      end
      
      # if the event is nil, and there is no :else clause,
      # throw an exception
      if next_state.nil?
        transition_error(event, @curr.state)
      end
      
      # first, check if we need to handle an error function for this state,
      # then check if we need to postprocess the event, this will act
      # as the "return" from any state transition (even self-looping transitions)
      if next_state == ERRSTATE
        if respond_to?("error_#{@curr.state}")
          ret_val = my_send("error_#{@curr.state}", event)
        else
          raise NoSuchTransitionException,
          "No valid transition #{event} for #{@curr.state}"
        end
      elsif respond_to?("post_#{@curr.state}")
        ret_val = my_send("post_#{@curr.state}", event)
      elsif respond_to?("post_cooked_#{curr.state}")
        ret_val = my_send("post_#{@curr.state}", cooked_event)
      end
      
      # actually transition, and make sure such a transition exists
      @curr = next_state unless next_state == ERRSTATE

      if @curr.nil?
        transition_error(event, @curr.state)
      end

      return ret_val
    end

    # Restart the current state to be the start state.
    def restart
      @curr = @start
    end

    # Equality is based on if all the states are the same, and if
    # the machines are currently in the same state.
    def ==(another_baby)
      if @curr != another_baby.curr
        return false
      end

      @states.keys.each do |k|
        if @states[k] != another_baby.states[k] then return false end 
      end

      return true
    end

    # Check if a method call is checking that state name.
    def method_missing(m, *a, &b)
      if m =~ /^([a-zA-Z_]+)\?$/
        state == m.to_s.gsub("?","").to_sym
      else
        raise NoMethodError
      end
    end

    private

    # Wrapper for our NoSuchTransitionException
    def transition_error(event, state)
      raise NoSuchTransitionException,
      "No valid transition #{event} for #{state}"
    end

    # A wrapper around send, using the arity restrictions assumed by BabyBots.
    def my_send(method_name, event=nil)
      m_arity = method(method_name).arity
      if m_arity == 0
        ret_val = send(method_name)
      elsif m_arity == 1 or m_arity == -1
        ret_val = send(method_name, event)
      else
        raise ArgumentError
      end
      return ret_val
    end
  end

end
