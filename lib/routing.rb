module RollAdminModel
  class Routing
    def self.connect_with(map)
      map.with_options :controller => 'admin_model' do |m|
        m.admin_model 'admin-model' ,:action => 'index'
        m.admin_model 'admin_model' ,:action => 'index'
        m.admin_model_list 'admin_model/list' ,:action => 'list'
        m.admin_model_show 'admin_model/show' ,:action => 'show'
        m.admin_model_destroy 'admin_model/destroy' ,:action => 'destroy'
        m.admin_model_delete 'admin_model/delete' ,:action => 'delete'
        m.admin_model_edit 'admin_model/edit' ,:action => 'edit'
        m.admin_model_edit 'admin_model/update' ,:action => 'update'
        m.admin_model_search 'admin_model/quick_search' ,:action => 'quick_search'
        m.admin_model_search 'admin_model/advance_search' ,:action => 'advance_search'
        m.admin_model_search 'admin_model/migration_information' ,:action => 'migration_information'
        m.admin_model_search 'admin_model/table_structure' ,:action => 'table_structure'
        m.admin_model_search 'admin_model/new' ,:action => 'new'
        m.admin_model_search 'admin_model/create' ,:action => 'create'
      end
    end
  end
end


def get_roll_admin_model_value_for_column(column,source)
  if column.type == :datetime
    tmp = source.send(column.name)
    tmp.strftime('%m/%d/%Y %H:%M:%S %p') unless tmp.blank?
  else
    source.send(column.name)  
  end
end


def roll_admin_model_ensure_update_allowed
  return true if Rails.env.development? || Rails.env.test?  

  proc = Object.const_get('ROLL_ADMIN_MODEL_UPDATE_ALLOWED') rescue nil
  return false unless proc
  
  output =  proc.call(self)
  Rails.logger.info("Authorization for admin_model update was called and the result was #{output}")
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



def roll_admin_model_has_many_count(model,send)
  model.send(send.intern).count
end


def get_belongs_to_class(model,belongs_to_string)
  tmp = model.send(belongs_to_string.intern)
  tmp.class.to_s if tmp
end

def get_has_many_class(model,belongs_to_string)
  tmp = model.send(belongs_to_string.intern)
  tmp.find(:first).class if tmp.count > 0
end

