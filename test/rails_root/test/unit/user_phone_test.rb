require "test_helper"
require "minitest/autorun"

class UserPhoneTest < MiniTest::Unit::TestCase

  def setup
    User.delete_all
    PhoneNumber.delete_all
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
    require 'ruby-debug'; debugger
    foreign_key = main_klass.reflections[hm_relationship].instance_variable_get('@active_record').name.foreign_key

    sql  = %Q{
      
      select count(*) 
      from #{main_klass.table_name}
      where users.id NOT IN (
        select #{hm_klass.table_name}.#{foreign_key}
        from #{hm_klass.table_name}
      )
    
    }

    u = User.find_by_sql(sql).first
    puts u

    u2 = u['count(*)']
    puts u2


    assert_equal 5, u2
  end
end

