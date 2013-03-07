When /^configured to display only (\d*) records per page$/ do |max_recs|
  AdminData.config do |config|
    config.number_of_records_per_page = max_recs.to_i
  end
end

def col_for( string )
  string.gsub(/^\:/,'').downcase.to_sym
end

def add_to( config, param_sym, key1, key2, val)  
  hash = config.send( param_sym )   
  assign_sym = (param_sym.to_s + '=').to_sym
  config.send( assign_sym, hash ||= {} )
  hash[ key1 ] ||= {}
  hash[ key1 ].store( key2, val )
end

# Assumes a table in the form:
# column,     alias
# :city_name, City Name    
When /^configured to rename (\w*) columns:$/ do |model, table|
  @last_model = model  
  AdminData.config do |config|
    table.hashes.each do |r|    
      add_to config, :column_headers, model, col_for(r['column']), r['alias']
    end
  end  
end

When /^configured to display (\w*) column ([\:\w]*) as "([^"]*)"$/ do   
  
  |model, col_name, new_name|
  
  @last_model = model  
  AdminData.config do |config|
    add_to config, :column_headers, model, col_for(col_name), new_name
  end  
end

# Specify models to hide: Model1, Model2, Model3
Given /^configuration to (hide|show) the association drop down for ([\w\, ]*)$/ do |action,mods|
  AdminData.config do |config|
    
    hash = config.drop_down_for_associations
    hash = {} if (hash == true || hash.nil?)
  
    if action == "hide"
      new_val = false
    else
      new_val = true
    end
    
    models = mods.split(', ')
    models.each do |model|
      hash.store( model.strip, new_val )
    end         
  
    config.drop_down_for_associations = hash
  end  
end
