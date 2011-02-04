module Processor
  attr_accessor :criteries, :elements
  
  @elements = Hash.new
  @criteries = Array.new
  
  def solve
    st = proc.elements.sort[proc.elements.length - 1][1].states
        # 
        # print path_to_state proc.elements['x1'].states['/x1']
        # print path_to_state proc.elements['x2'].states['/x2']
        # print path_to_state proc.elements['x3'].states['/x3']
        # print path_to_state proc.elements['x4'].states['/x4a']
        # print path_to_state proc.elements['x4'].states['/x4o']    
        # 
    # print path_to_state proc.elements['x1'].states['/x1']
    # print path_to_state proc.elements['x2'].states['/x2']
    # print path_to_state proc.elements['x3'].states['/x3a']
    # print path_to_state proc.elements['x3'].states['/x3o']
    proc.criteries.each do |crit|
      s = crit.clone
      crit.scan(/\/x\d{1,2}[oa]?/) do |m|
        s.gsub!(m, (path_to_state2 proc.elements[m.scan(/x\d{1,2}/)[0]].states[m]))
      end
      print s
    end
  end
  
  def path_to_state state
    m = state.name
    unless state.is_initial
      state.previous_states.each_value do |prev|
        state.events.each_value do |ev|
          z = prev.name + '('+ev.name+')'
          if state.events[z] != nil
            m += ' <= ' + state.events[z].name
            m += '(' + state.events[z].general_condition
            unless state.events[z].second_condition == 'nil'
              m += ', ' + state.events[z].second_condition# path_to_state()
            end        
            m += ') <= ' + path_to_state(prev) + "\n"
          end
        end
      end
    end
    m
  end
  
  def path_to_state2 state
    m = ''
    unless state.is_initial
      state.previous_states.each_value do |prev|
        state.events.each_value do |ev|
          z = prev.name + '('+ev.name+')'
          if state.events[z] != nil
            m += state.events[z].name
            if state.events[z].previous_state.is_initial
              m += '(' + state.events[z].general_condition
            else
              m += '(' + (path_to_state2 state.events[z].previous_state)
            end
            unless state.events[z].second_condition == 'nil'
              crit = state.events[z].second_condition
              s = crit.clone
              p s
              crit.scan(/\/x\d{1,2}[oa]?/) do |v|
                s.gsub!(v, (path_to_state2 proc.elements[v.scan(/x\d{1,2}/)[0]].states[v]))
              end
              m += ', ' + s# path_to_state()
            end        
            m += ") + "#path_to_state2(prev) + ") + "
          end
        end
      end
    end
    m[0..(m.length - 3)]
  end
  
  def read_file path
    file = File.open path, 'r'
    file = file.readlines
    unless file.empty?
      file.each do |line|
        case line
          when /^\/x\d{1,2}/ then
            state_analyse line
          when /\/Y/ then
            proc.criteries << line
            # p line
          else next
        end
      end
      sec_cond_analyse
    end
  end
  
  def state_analyse line
    r = line.match(/x\d{1,2}/)[0]
    e = nil
    x = nil
    x_s = nil
    
    unless proc.elements.has_key? r
      new_eval r + ' = Element.new \'' + r + '\'' 
      new_eval r + 'w = State.new \'' + r + '\', ' + r + ', true'
      x_s = r + 'w'
      new_eval 'x = ' + x_s
    else
      new_eval r + ' = proc.elements[\'' + r + '\']'
    end
    new_eval 'e = ' + r
    
    e = $common_binding.eval('e')
    
    if line.match(/^\/x\d{1,2}h/)
      new_eval r + 'h = State.new \'/' + r + 'h\', ' + r + ', false, ' + 
        get_prev(line, e)
      x_s = r + 'h'
      new_eval 'x = ' + x_s
    elsif line.match(/^\/x\d{1,2}[ ]/)
      new_eval r + 'b = State.new \'/' + r + '\', ' + r + ', false, ' + 
        get_prev(line, e)
      x_s = r + 'b'
      new_eval 'x = ' + x_s
    elsif line.match(/^\/x\d{1,2}o/)
      new_eval r + 'o = State.new \'/' + r + 'o\', ' + r + ', false, ' + 
        get_prev(line, e)
      x_s = r + 'o'
      new_eval 'x = ' + x_s
    elsif line.match(/^\/x\d{1,2}a/)
      new_eval r + 'a = State.new \'/' + r + 'a\', ' + r + ', false, ' + 
        get_prev(line, e)
      x_s = r + 'a'
      new_eval 'x = ' + x_s
    end
    
    x = $common_binding.eval('x')
    
    # p 'state = ' + x.name + ' :'
    # x.previous_states.each_key {|pr| p pr}
    line.scan(/w\d{1,2}[a-z]?\([^\)]+\)/) do |m|
      # p r + ' - ' + m
      # m.each do |w|
        if m.match(/w\d{1,2}\(/)
          gen_cond = m.match(/\(([^,]+)[,|\)]/)
          gen_cond = x.previous_states[gen_cond[1]]
          sec_cond = 'nil'
          if m.match(/,[ ]?(.+)\)/)
            sec_cond = m.match(/,[ ]?(.+)\)/)[1]
          end
          ev = nil
          new_eval m.match(/^(.+)\(/)[1] + ' = Event.new \'' + m.match(/^(.+)\(/)[1] +
           '\', ' + r + ', gen_cond, ' + x_s + ', nil, \'' + sec_cond + '\''
          new_eval 'ev = ' + m.match(/^(.+)\(/)[1]
          # p ev.name
        elsif m.match(/w\d{1,2}[he]\(/)
          gen_cond = m.match(/\(([^,]+)[,|\)]/)
          gen_cond = x.previous_states[gen_cond[1]]
          sec_cond = 'nil'
          if m.match(/,[ ]?(.+)\)/)
           sec_cond = m.match(/,[ ]?(.+)\)/)[1]
          end
          ev = nil
          new_eval m.match(/^(.+)\(/)[1] + ' = Event.new \'' + m.match(/^(.+)\(/)[1] +
          '\', ' + r + ', gen_cond, ' + x_s + ', nil, \'' + sec_cond + '\''
          new_eval 'ev = ' + m.match(/^(.+)\(/)[1]
          # p ev.name
        elsif  m.match(/w\d{1,2}[oa]\(/)
          gen_cond = m.match(/\(([^,]+)[,|\)]/)
          gen_cond = x.previous_states[gen_cond[1]]
          sec_cond = 'nil'
          if m.match(/,[ ]?(.+)\)/)
           sec_cond = m.match(/,[ ]?(.+)\)/)[1]
          end
          ev = nil
          new_eval m.match(/^(.+)\(/)[1] + ' = Event.new \'' + m.match(/^(.+)\(/)[1] +
          '\', ' + r + ', gen_cond, ' + x_s + ', nil, \'' + sec_cond + '\''
          new_eval 'ev = ' + m.match(/^(.+)\(/)[1]
          # p ev.name
        # end
      end
    end
  end
  
  def sec_cond_analyse
    proc.elements.each_value do |el|
      el.events.each_value do |ev|
        ps = ev.previous_state
        unless ps.is_initial
          ps.events.each do |k,v|
            ps.queue_push v if (v.target_state == ps) && !(ps.queue.has_value? v)
          end
        else
          ps.queue_push ev if !(ps.queue.has_value? ev)
        end
        if ev.second_condition != 'nil'
          inner_cond_analyse ev.second_condition, ps
        # p ev.name + ' - ' + ev.general_condition.to_s
        end
        # p ev.target_state.name + ' :'
        # ps.queue.sort.each {|k| p ' ' + k[1].name }
      end
    end
  end
  
  def ev_analysis ev, state
    ps = ev.previous_state
    unless ps.is_initial
      ps.events.each do |k,v|
        state.queue_push v if (v.target_state == ps) && !(state.queue.has_value? v)
      end
    else
      state.queue_push ev if !(state.queue.has_value? ev)
    end
    if ev.second_condition != 'nil'
      inner_cond_analyse ev.second_condition, ps
    end
  end
  
  def inner_cond_analyse line, state
    if line.match /\(.+\)/
      inner_cond_analyse line.match(/\((.+)\)/)[1], state
    else
      line.scan(/[\/]?x\d{1,2}[hoa]?/).each do |st|
        el = proc.elements[st.match(/(x\d{1,2})/)[1]]
        ps = el.states[st]
        ps.events.each do |k,v|
          ev_analysis v, state
          state.queue_push v if (v.target_state == ps) && !(state.queue.has_value? v)
        end
      end
    end
  end
  
  def get_prev(line, element)
    cond = Array.new
    line.scan(/w\d{1,2}[a-z]?\([^\)]+\)/) do |m|
      # p r + ' - ' + m
      # m.each do |w|
        c = element.states[m.match(/\(([^,]+)[,|\)]/)[1]].name
        # c = c + 'w' if c.match(/^x\d{1,2}$/) 
        # c = c[1..(c.length-1)] if c.match(/^\/x\d{1,2}h$/) 
        cond << c unless cond.include? c
      # end
    end
    r = '['
    cond.each {|c| r += '\'' + c + '\','}
    r = r[0..(r.length-2)] + ']'
  end
  
  def all_elements
    unless proc.elements.nil?
      proc.elements.each do |k,v| 
        p 'el = ' + k
        puts "  states: \n" + v.states_list 
        puts "  events: \n" + v.events_list
        p '-------------'
      end
    end
    unless proc.criteries.nil?
      proc.criteries.each { |e| p e }
    end
  end
  
  def proc
    Processor
  end
  
  def new_eval(string)
    $common_binding ||= binding
    $common_binding = $common_binding.eval string + "; binding"    
  end
end