require "test_helper"
require "minitest/autorun"

class UserPhoneTest < MiniTest::Unit::TestCase

  def setup
    User.delete_all
    PhoneNumber.delete_all
  end

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

  def count_of_main_klass_records_in_hm_klass(main_klass, hm_klass, hm_relationship_name)
    foreign_key = main_klass.reflections[hm_relationship_name].instance_variable_get('@active_record').name.foreign_key
    raise 'foreign_key is nil' unless foreign_key

    sql = %Q{
    
      select #{main_klass.table_name}.id, count(#{hm_klass.table_name}.id)
      from #{main_klass.table_name} join #{hm_klass.table_name} on #{main_klass.table_name}.id = #{hm_klass.table_name}.#{foreign_key}
      group by #{main_klass.table_name}.id
      having count(#{hm_klass.table_name}.id) > 0
    }

    main_klass.find_by_sql(sql).size
  end

  def test_pie_chart_for_user_with_phones_vs_users_without_phones
    5.times { Factory(:user) }
    3.times do
      user = Factory(:user)
      Factory(:phone_number, :user => user)
    end
    assert_equal 8, User.count
    assert_equal 3, PhoneNumber.count

    main_klass = User
    hm_klass = PhoneNumber
    hm_relationship = :phone_numbers

    assert_equal 5, count_of_main_klass_records_not_in_hm_klass(User, PhoneNumber, :phone_numbers)
    assert_equal 3, count_of_main_klass_records_in_hm_klass(User, PhoneNumber, :phone_numbers)
  end
end

