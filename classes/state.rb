class State
  attr_reader :name, :element, :is_initial
  attr_accessor :previous_states, :possibles, :events, :queue
  @is_initial = false
  
  def initialize(name, element, is_initial=nil, previous_states=nil, possibles=nil)
    @name = name
    @element = element
    @previous_states = Hash.new
    @possibles = Hash.new
    @events = Hash.new
    @queue = Hash.new
    element.states[@name] = self 
    
    @is_initial = is_initial unless is_initial.nil?
    
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
        p.previous_states[@name] = self unless p.previous_states.has_key? @name
      end
    end
  end
  
  def queue_push obj
    @queue[(@queue.nil? ? 0 : @queue.length)] = obj
    nil
  end
  
  def previous_list
    s = ''
    previous_states.each_key do |ps|
      s += ps + "\n"
    end
    
    s
  end
  def possibles_list
    s = ''
    possibles.each_key do |pos|
      s += pos + "\n"
    end
    
    s
  end
  
end