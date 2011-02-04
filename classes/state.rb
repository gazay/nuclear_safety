class State
  attr_reader :name, :element, :is_initial
  attr_accessor :previous_states, :possibles, :events, :queue
  @is_initial = false
  
  def initialize(name, element, is_initial=nil, previous_states=nil, possibles=nil)
    @name = name
    @element = element
    @previous_states, @possibles, @events, @queue = {}, {}, {}, {}
    element.states[@name] = self 
    
    @is_initial = is_initial if is_initial
    
    unless previous_states.nil?
      previous_states.each do |pr|
        @previous_states[pr] = element.states[pr]
        element.states[pr].possibles[@name] = 
          self unless element.states[pr].possibles.has_key? @name
      end
    end
    
    unless possibles.nil?
      possibles.each do |p|
        @possible_states[p.name] = p
        p.previous_states[@name] = 
          self unless p.previous_states.has_key? @name
      end
    end
  end
  
  def queue_push obj
    @queue[(@queue.nil? ? 0 : @queue.length)] = obj
    nil
  end
  
  def previous_list
    output = ''
    previous_states.each_key do |ps|
      output += ps + "\n"
    end
    
    output
  end
  
  def possibles_list
    output = ''
    possibles.each_key do |pos|
      output += pos + "\n"
    end
    
    output
  end
end