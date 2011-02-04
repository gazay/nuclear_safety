require './classes/element.rb'
require './classes/state.rb'
require './classes/event.rb'

read_file './data/5elements.txt'

# path_to_state proc.elements['x2'].states['/x2']

print "\n\n"
p '--------------------------------------'
p '------------all elements--------------'
p '--------------------------------------'
print "\n\n"
all_elements
solve
# x1 = Element.new 'x1'
# x1_w = State.new 'x1', x1, true
# x1_b = State.new '/x1', x1, false, [x1_w]
# 
# x2 = Element.new 'x2'
# x2_w = State.new 'x2', x2, true
# x2_h = State.new '/x2h', x2, false, [x2_w]
# x2_b = State.new '/x2', x2, false, [x2_w, x2_h]
# 
# x3 = Element.new 'x3'
# x3_w = State.new 'x3', x3, true
# x3_o = State.new '/x3o', x3, false, [x3_w]
# x3_a = State.new '/x3a', x3, false, [x3_w]
# 
# w1 = Event.new 'w1', x1, x1_w, x1_b
# w2 = Event.new 'w2', x2, x2_w, x2_b, nil, '/x1'
# v2 = Event.new 'w2h', x2, x2_w, x2_h, nil, 'x1'
# w2h = Event.new 'w2h', x2, x2_h, x2_b
# w3o = Event.new 'w3o', x3, x3_w, x3_o, nil, '/x1 * x2'
# w3a = Event.new 'w3a', x3, x3_w, x3_a, nil, '/x2'
# 
# puts x3.states_events_list
# puts
# puts path_to_state x2_b