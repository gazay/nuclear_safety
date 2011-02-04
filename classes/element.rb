require './classes/processor.rb'

include Processor

class Element
  attr_accessor :current_state, :states, :events
  attr_reader :name
  
  def initialize(name)
    @name = name
    @states = Hash.new
    @events = Hash.new
    
    proc.elements[name] = self unless proc.elements.keys.include? name
  end
  
  def states_list
    s = ''
    @states.each do |state, v|
      s += '    ' + state + ":\n"
      v.events.each do |k,v|
        s += '      ' + v.name + '(' + v.general_condition 
        s += ', ' + v.second_condition if v.second_condition != 'nil'
        s += ")\n"
      end
    end
    
    s
  end
  
  def events_list
    s = ''
    @events.each do |k,v|
      s += '    ' + v.previous_state.name + ' => ' + v.name + 
        '(' + v.general_condition 
      s += ', ' + v.second_condition if v.second_condition != 'nil'
      s += ') => ' + v.target_state.name + "\n"
    end
    
    s
  end
  
  def states_events_list
    s = ''
    @events.each_value do |event|
      s += event.previous_state.name + ' => ' + event.name
      s += '(' + event.general_condition
      unless event.second_condition.nil?
        s += ', ' + event.second_condition
      end
      s += ') => ' + event.target_state.name + "\n"
    end
    
    s
  end
end