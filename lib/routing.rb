module AdminData
  class Routing
    def self.connect_with(map)
      map.with_options :controller => 'admin_data' do |m|
        m.admin_data 'admin-data' ,:action => 'index'
        m.admin_data 'admin_data' ,:action => 'index'
        m.admin_data_list 'admin_data/list' ,:action => 'list'
        m.admin_data_show 'admin_data/show' ,:action => 'show'
        m.admin_data_destroy 'admin_data/destroy' ,:action => 'destroy'
        m.admin_data_delete 'admin_data/delete' ,:action => 'delete'
        m.admin_data_edit 'admin_data/edit' ,:action => 'edit'
        m.admin_data_edit 'admin_data/update' ,:action => 'update'
        m.admin_data_search 'admin_data/quick_search' ,:action => 'quick_search'
        m.admin_data_search 'admin_data/advance_search' ,:action => 'advance_search'
        m.admin_data_search 'admin_data/migration_information' ,:action => 'migration_information'
        m.admin_data_search 'admin_data/table_structure' ,:action => 'table_structure'
        m.admin_data_search 'admin_data/new' ,:action => 'new'
        m.admin_data_search 'admin_data/create' ,:action => 'create'
      end
    end
  end
end


def get_admin_data_value_for_column(column,source)
  if column.type == :datetime
    tmp = source.send(column.name)
    tmp.strftime('%m/%d/%Y %H:%M:%S %p') unless tmp.blank?
  else
    source.send(column.name)  
  end
end


def admin_data_ensure_update_allowed
  return true if Rails.env.development? || Rails.env.test?  

  proc = Object.const_get('ADMIN_DATA_UPDATE_ALLOWED') rescue nil
  return false unless proc
  
  output =  proc.call(self)
  Rails.logger.info("Authorization for admin_data update was called and the result was #{output}")
  output
end 

def belongs_to_what(klass_name)
  @klass = Object.const_get(klass_name)
  output = []
  @klass.reflections.each do |key,value|
    output << value.name.to_s if value.macro.to_s == 'belongs_to'
  end
  output
end

def has_one_what(klass_name)
  @klass = Object.const_get(klass_name)
  output = []
  @klass.reflections.each do |key,value|
    output << value.name.to_s if value.macro.to_s == 'has_one'
  end
  output
end

def has_many_what(klass_name)
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

def get_belongs_to_class(model,belongs_to_string)
  begin
    tmp = model.send(belongs_to_string.intern)
    tmp.class.to_s if tmp
  rescue
    nil
  end
end

def get_has_many_class(model,belongs_to_string)
  begin
    tmp = model.send(belongs_to_string.intern)
    tmp.find(:first).class if tmp.count > 0
  rescue
    nil
  end
end