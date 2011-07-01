require "test_helper"
require "minitest/autorun"

class UserPhoneTest < MiniTest::Unit::TestCase

  def setup
    User.delete_all
    PhoneNumber.delete_all
  end


  def count_of_main_klass_records_in_hm_klass(main_klass, hm_klass, hm_relationship_name, count = nil)
    foreign_key = main_klass.reflections[hm_relationship_name].instance_variable_get('@active_record').name.foreign_key
    raise 'foreign_key is nil' unless foreign_key

    having_sql = if count
      "having count(#{hm_klass.table_name}.id) = #{count}"
    else
      "having count(#{hm_klass.table_name}.id) > 0"
    end

    sql = %Q{
    
      select #{main_klass.table_name}.id, count(#{hm_klass.table_name}.id)
      from #{main_klass.table_name} join #{hm_klass.table_name} on #{main_klass.table_name}.id = #{hm_klass.table_name}.#{foreign_key}
      group by #{main_klass.table_name}.id
      #{having_sql}
    }

    main_klass.find_by_sql(sql).size
  end

  def test_pie_chart_for_user_with_1_phone_vs_users_with_2_phones_vs_users_with_0_phone
    5.times { Factory(:user) }
    4.times do
      user = Factory(:user)
      Factory(:phone_number, :user => user)
    end
    2.times do
      user = Factory(:user)
      Factory(:phone_number, :user => user)
      Factory(:phone_number, :user => user)
    end

    assert_equal 11, User.count
    assert_equal 8, PhoneNumber.count

    main_klass = User
    hm_klass = PhoneNumber
    hm_relationship = :phone_numbers

    assert_equal 5, AdminData::Analytics::HmAssociation.count_of_main_klass_records_not_in_hm_klass(User, PhoneNumber, :phone_numbers)
    assert_equal 4, AdminData::Analytics::HmAssociation.count_of_main_klass_records_in_hm_klass(User, PhoneNumber, :phone_numbers, 1)
    assert_equal 2, AdminData::Analytics::HmAssociation.count_of_main_klass_records_in_hm_klass(User, PhoneNumber, :phone_numbers, 2)
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

    assert_equal 5, AdminData::Analytics::HmAssociation.count_of_main_klass_records_not_in_hm_klass(User, PhoneNumber, :phone_numbers)
    assert_equal 3, AdminData::Analytics::HmAssociation.count_of_main_klass_records_in_hm_klass(User, PhoneNumber, :phone_numbers)
  end


end

