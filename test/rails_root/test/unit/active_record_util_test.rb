require "test_helper"
require "minitest/autorun"

class ActiveRecordUtilTest < MiniTest::Unit::TestCase

  def test_foreign_key_for_has_many_for_standard_case
    result = AdminData::ActiveRecordUtil.foreign_key_for_has_many(User, :phone_numbers)
    assert_equal 'user_id', result
  end

  def test_foreign_key_for_has_many_for_non_standard_case
    result = AdminData::ActiveRecordUtil.foreign_key_for_has_many(Car, :brakes)
    assert_equal 'vehicle_id', result
  end

end

