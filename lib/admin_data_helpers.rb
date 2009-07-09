def build_drop_down_for_klasses
  @klasses.inject([]) do |result,klass|
    result << [klass.name, "http://#{request.host_with_port}/admin_data/list?klass=#{klass.name}"]
  end
end

def build_sort_options(klass)
  output = []
  klass.columns.each do |column|
    name = column.name

    selected_text = params[:sortby] == "#{name} desc" ? "selected='selected'" : ''
    output << "<option value='#{name} desc' #{selected_text}>&nbsp;#{name} desc</option>"

    selected_text = params[:sortby] == "#{name} asc" ? "selected='selected'" : ''
    output << "<option value='#{name} asc' #{selected_text}>&nbsp;#{name} asc</option>"
  end
  output.join
end
          
def erb_file(*args)
  s = args
  b = []
  b << RAILS_ROOT
  b << 'vendor'
  b << 'plugins'
  b << 'admin_data'
  tmp = b + args
  ERB.new(File.read(File.join(tmp))).result(binding)      
end

def admin_data_default_string(value)
  case value
  when BigDecimal
    value.to_s
  when Date, DateTime, Time
    "'#{value.to_s(:db)}'"
  else
    value.inspect
  end
end


def admin_data_am_i_active(action_name)
  action_names = action_name.split
  action_names.include?(params[:action]) ? 'active' : ''
end

def admin_data_is_allowed_to_update?
  return true if Rails.env.development? || Rails.env.test?  
  begin
    output = Object.const_get('ADMIN_DATA_UPDATE_AUTHORIZATION').call(self)
    Rails.logger.info("Authentication for ADMIN_DATA_UPDATE_AUTHORIZATION was called and the result was #{output}")    
    return false unless output    
  rescue NameError => e
    Rails.logger.info("ADMIN_DATA_UPDATE_AUTHORIZATION is not declared. " + e.to_s)      
    return false
  end
  true
end 

def admin_data_is_allowed_to_view?
  return true if Rails.env.development? || Rails.env.test?  
  begin
    output = Object.const_get('ADMIN_DATA_VIEW_AUTHORIZATION').call(self)
    Rails.logger.info("Authentication for ADMIN_DATA_VIEW_AUTHORIZATION was called and the result was #{output}")    
    return false unless output    
  rescue NameError => e
    Rails.logger.info("ADMIN_DATA_VIEW_AUTHORIZATION is not declared. " + e.to_s)      
    return false
  end
  true
end 

def admin_data_get_value_for_column(column,source)
  if column.type == :datetime
    tmp = source.send(column.name)
    tmp.strftime('%m/%d/%Y %H:%M:%S %p') unless tmp.blank?
  else
    source.send(column.name)  
  end
end

def admin_data_belongs_to_what(klass_name)
  @klass = Object.const_get(klass_name)
  output = []
  @klass.reflections.each do |key,value|
    output << value.name.to_s if value.macro.to_s == 'belongs_to'
  end
  output
end

def admin_data_has_one_what(klass_name)
  @klass = Object.const_get(klass_name)
  output = []
  @klass.reflections.each do |key,value|
    output << value.name.to_s if value.macro.to_s == 'has_one'
  end
  output
end

def admin_data_has_many_what(klass_name)
  @klass = Object.const_get(klass_name)
  output = []
  @klass.reflections.each do |key,value|
    output << value.name.to_s if value.macro.to_s == 'has_many'
  end
  output
end

def admin_data_has_many_count(model,send)
  model.send(send.intern).count
end

def admin_data_get_belongs_to_class(model,belongs_to_string)
  begin
    tmp = model.send(belongs_to_string.intern)
    tmp.class.to_s if tmp
  rescue
    nil
  end
end

def admin_data_get_has_many_class(model,belongs_to_string)
  begin
    tmp = model.send(belongs_to_string.intern)
    tmp.find(:first).class if tmp.count > 0
  rescue
    nil
  end
end
