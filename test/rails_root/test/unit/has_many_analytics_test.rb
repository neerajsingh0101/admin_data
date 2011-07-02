require "test_helper"
require "minitest/autorun"

class HasManyAnalyticsTest < MiniTest::Unit::TestCase

  def setup
    User.delete_all
    PhoneNumber.delete_all
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

    hma = AdminData::Analytics::HasManyAssociation.new(User, PhoneNumber, :phone_numbers)

    assert_equal 5, hma.not_in_count
    assert_equal 6, hma.in_count
    assert_equal 4, hma.in_count(:count => 1, :operator => '=')
    assert_equal 2, hma.in_count(:count => 2, :operator => '=')
    assert_equal 6, hma.in_count(:count => 1, :operator => '>=')
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

    hma = AdminData::Analytics::HasManyAssociation.new(User, PhoneNumber, :phone_numbers)

    assert_equal 5, hma.not_in_count
    assert_equal 3, hma.in_count
  end

  def test_pie_chart_for_user_with_phones_vs_users_without_phones_with_user_id_null
    5.times { Factory(:user) }
    3.times do
      user = Factory(:user)
      Factory(:phone_number, :user => user)
    end
    assert_equal 8, User.count
    assert_equal 3, PhoneNumber.count

    #create a phone with user_id null
    PhoneNumber.create!(:number => '123-456-7890')

    main_klass = User
    hm_klass = PhoneNumber
    hm_relationship = :phone_numbers

    hma = AdminData::Analytics::HasManyAssociation.new(User, PhoneNumber, :phone_numbers)

    assert_equal 1, PhoneNumber.count(:conditions => {:user_id => nil})
    assert_equal nil, PhoneNumber.find_by_user_id(nil).user_id
    assert_equal 5, hma.not_in_count
    assert_equal 3, hma.in_count
  end

end
