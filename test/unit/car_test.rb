require "test_helper"

class CarTest < ActiveSupport::TestCase

=begin
  def setup
    Car.delete_all
    new_time = Time.local(2011, 6, 23, 12, 0, 0)
    Timecop.freeze(new_time)
  end

  def test_by_default_all_values_are_zero
    now = Time.now.utc
    result = AdminData::Analytics.daily_report(Car, now)
    expected = []
    expected << ["'2011-05-23'", 0] << ["'2011-05-24'", 0] << ["'2011-05-25'", 0] << ["'2011-05-26'", 0] << ["'2011-05-27'", 0]
    expected << ["'2011-05-28'", 0] << ["'2011-05-29'", 0] << ["'2011-05-30'", 0] << ["'2011-05-31'", 0] 
    expected << ["'2011-06-01'", 0] << ["'2011-06-02'", 0]
    expected << ["'2011-06-03'", 0] << ["'2011-06-04'", 0] << ["'2011-06-05'", 0] << ["'2011-06-06'", 0] << ["'2011-06-07'", 0]
    expected << ["'2011-06-08'", 0] << ["'2011-06-09'", 0] << ["'2011-06-10'", 0] << ["'2011-06-11'", 0] << ["'2011-06-12'", 0]
    expected << ["'2011-06-13'", 0] << ["'2011-06-14'", 0] << ["'2011-06-15'", 0] << ["'2011-06-16'", 0] << ["'2011-06-17'", 0]
    expected << ["'2011-06-18'", 0] << ["'2011-06-19'", 0] << ["'2011-06-20'", 0] << ["'2011-06-21'", 0] << ["'2011-06-22'", 0]
    expected << ["'2011-06-23'", 0]

    assert_all(expected, result)
  end

  def test_yesterday_vs_today
    now = Time.now.utc
    y = now.yesterday
    Car.create!(:created_at => now.ago(3.days)) 
    Car.create!(:created_at => y) 
    Car.create!(:created_at => y) 
    Car.create!(:created_at => now) 
    result = AdminData::Analytics.daily_report(Car, now)
    expected = []
    expected << ["'2011-05-23'", 0] << ["'2011-05-24'", 0] << ["'2011-05-25'", 0] << ["'2011-05-26'", 0] << ["'2011-05-27'", 0]
    expected << ["'2011-05-28'", 0] << ["'2011-05-29'", 0] << ["'2011-05-30'", 0] << ["'2011-05-31'", 0] 
    expected << ["'2011-06-01'", 0] << ["'2011-06-02'", 0]
    expected << ["'2011-06-03'", 0] << ["'2011-06-04'", 0] << ["'2011-06-05'", 0] << ["'2011-06-06'", 0] << ["'2011-06-07'", 0]
    expected << ["'2011-06-08'", 0] << ["'2011-06-09'", 0] << ["'2011-06-10'", 0] << ["'2011-06-11'", 0] << ["'2011-06-12'", 0]
    expected << ["'2011-06-13'", 0] << ["'2011-06-14'", 0] << ["'2011-06-15'", 0] << ["'2011-06-16'", 0] << ["'2011-06-17'", 0]
    expected << ["'2011-06-18'", 0] << ["'2011-06-19'", 0] << ["'2011-06-20'", 1] << ["'2011-06-21'", 0] << ["'2011-06-22'", 2]
    expected << ["'2011-06-23'", 1]

    assert_all(expected, result)
  end


  def test_one_year_data_with_data_for_each_month
    now = Time.now.utc
    Car.create!(:created_at => now) 
    2.times { cc(now.ago(1.month)) }; 3.times { cc(now.ago(2.month)) }; 4.times { cc(now.ago(3.month)) }
    5.times { cc(now.ago(4.month)) }; 6.times { cc(now.ago(5.month)) }; 7.times { cc(now.ago(6.month)) }
    8.times { cc(now.ago(7.month)) }; 9.times { cc(now.ago(8.month)) }; 10.times { cc(now.ago(9.month)) }
    11.times { cc(now.ago(10.month)) }; 12.times { cc(now.ago(11.month)) }; 13.times { cc(now.ago(12.month)) }
    14.times { cc(now.ago(13.month)) }; 15.times { cc(now.ago(14.month)) }; 
    
    result = AdminData::Analytics.monthly_report(Car, now)

    expected = []
    expected << ["'Jul-2010'", 12] << ["'Aug-2010'", 11] << ["'Sep-2010'", 10] << ["'Oct-2010'", 9]
    expected << ["'Nov-2010'", 8] << ["'Dec-2010'", 7] << ["'Jan-2011'", 6] << ["'Feb-2011'", 5]
    expected << ["'Mar-2011'", 4] << ["'Apr-2011'", 3] << ["'May-2011'", 2] << ["'Jun-2011'", 1]

    assert_all(expected, result)
  end

  def test_one_year_data_with_data_missing_for_last_9_months
    Car.delete_all
    now = Time.now.utc
    Car.create!(:created_at => now) 
    2.times { cc(now.ago(1.month)) }; 3.times { cc(now.ago(2.month)) };
    
    result = AdminData::Analytics.monthly_report(Car, now)

    expected = []
    expected << ["'Jul-2010'", 0] << ["'Aug-2010'", 0] << ["'Sep-2010'", 0] << ["'Oct-2010'", 0]
    expected << ["'Nov-2010'", 0] << ["'Dec-2010'", 0] << ["'Jan-2011'", 0] << ["'Feb-2011'", 0]
    expected << ["'Mar-2011'", 0] << ["'Apr-2011'", 3] << ["'May-2011'", 2] << ["'Jun-2011'", 1]

    assert_all(expected, result)
  end

  def assert_all(expected, result)
    assert_equal expected.size, result.size
    expected.each_with_index do |e, i| 
      assert_equal e, result[i]
    end
  end

  def cc(time)
    Car.create!(:created_at => time)
  end
=end
end
