# A tiny finite-state automata library.
#
# Author:: Justin Hamilton (mailto:justinanthonyhamilton@gmail.com)
# Copyright :: BSD2 (see LICENSE for more details)

module BabyBots

  # Error to handle attempts to transition to a state that does not exist.
  class NoSuchStateException < Exception
  end

  # Error to handle attempts to use a transition that does not exist.
  class NoSuchTransitionException < Exception
  end

  # A tiny finite-state automata class.
  class BabyBot
    attr_accessor :curr, :states, :start

    # Accepts an optional hash of states.
    def initialize(states={})
      # Hash of state names to state objects
      @states = states
      # Initial state
      @start = nil
      # Current state
      @curr = nil
    end

    # Adds a new state to the finite-state automata, also accepts
    # an optional start flag, which will set the supplied state as the initial
    # state. Note that this machine may only have one start state. Additionally,
    # adding the first start state will set @curr to be this state, after this
    # has been done @curr will remain on whatever state it is currently residing
    # on, and must be reset using the reset method.
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
        cooked_event = send("pre_#{@curr.state}", event)
      end

      # calculate the next state
      if cooked_event
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

    # Reset the current state to be the start state.
    def restart
      @curr = @start
    end
  end

end
