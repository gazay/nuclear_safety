class Event
  attr_reader :name, :element, :previous_state, :target_state
  attr_accessor :general_condition, :second_condition
  
  def initialize(name, element, previous_state, target_state, general_condition=nil, second_condition=nil)
    @name = name
    @element = element
    @previous_state = previous_state
    @target_state = target_state
    @previous_state.events[@target_state.name + '(' + name + ')'] = self
    @target_state.events[@previous_state.name + '(' + name + ')'] = self
    if general_condition.nil?
      @general_condition = previous_state.name
    else
      @general_condition = general_condition
    end 
    @second_condition = second_condition
    
    @element.events[@name] = self
  end
end