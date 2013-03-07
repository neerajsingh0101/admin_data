require "test_helper"

class UserPhoneTest < ActiveSupport::TestCase
  def count_of_main_klass_records_not_in_hm_klass(main_klass, hm_klass, hm_relationship_name)
    foreign_key = main_klass.reflections[hm_relationship_name].instance_variable_get('@active_record').name.foreign_key
    raise 'foreign_key is nil' unless foreign_key
    sql  = %Q{
      select count(*) as count_data
      from #{main_klass.table_name}
      where users.id NOT IN (
        select #{hm_klass.table_name}.#{foreign_key}
        from #{hm_klass.table_name}
      )
    }
    record = main_klass.find_by_sql(sql).first
    record['count_data'].to_i
  end
end

