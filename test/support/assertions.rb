require 'active_support/test_case'

class ActiveSupport::TestCase
  def assert_not(assertion)
    assert !assertion
  end

  def assert_blank(assertion)
    assert assertion.blank?
  end

  def assert_not_blank(assertion)
    assert !assertion.blank?
  end

  def assert_equal_sql(sql1, sql2)
    assert_equal sql1.squeeze(" ").strip, sql2.squeeze(" ").strip
  end

end
