def admin_data_is_allowed_to_update?
  return true if Rails.env.development? || Rails.env.test?  
  begin
    output = Object.const_get('ADMIN_DATA_UPDATE_ALLOWED').call(self)
    Rails.logger.info("Authentication for ADMIN_DATA_UPDATE_ALLOWED was called and the result was #{output}")    
    return false unless output    
  rescue NameError => e
    Rails.logger.info("ADMIN_DATA_UPDATE_ALLOWED is not declared. " + e.to_s)      
    return false
  end
  true
end 

def admin_data_is_allowed_to_view?
  return true if Rails.env.development? || Rails.env.test?  
  begin
    output = Object.const_get('ADMIN_DATA_AUTH').call(self)
    Rails.logger.info("Authentication for ADMIN_DATA_AUTH was called and the result was #{output}")    
    return false unless output    
  rescue NameError => e
    Rails.logger.info("ADMIN_DATA_AUTH is not declared. " + e.to_s)      
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