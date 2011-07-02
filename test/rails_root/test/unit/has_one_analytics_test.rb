require "test_helper"
require "minitest/autorun"

class HasOneAalyticsTest < MiniTest::Unit::TestCase

  def setup
    User.delete_all
    Website.delete_all
  end

  def test_pie_chart_for_user_with_no_website_vs_users_with_website
    5.times { Factory(:user) }
    4.times do
      user = Factory(:user)
      Factory(:website, :user => user)
    end

    assert_equal 9, User.count
    assert_equal 4, Website.count

    main_klass = User
    ho_klass = PhoneNumber
    ho_relationship = :website

    hoa = AdminData::Analytics::HasOneAssociation.new(User, Website, :website)

    assert_equal 5, hoa.not_in_count
    assert_equal 4, hoa.in_count
  end

end
