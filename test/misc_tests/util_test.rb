require File.join(File.dirname(__FILE__) ,'..', 'test_helper')

require File.expand_path(File.join(File.dirname(__FILE__), '../../../admin_data/lib/admin_data/util.rb'))

class AdminDataUtilTest < Test::Unit::TestCase
  context 'has_one' do
    subject { AdminData::Util.has_one_what(Vehicle::Car) }
    setup { @instance = Vehicle::Car.create(:year => 2000, :brand => 'bmw') }
    should 'be engine' do
      assert subject
      assert subject.size,1
      assert_equal subject[0],"engine"
    end
    should 'respond_to? has_one' do
      assert @instance.respond_to?(subject[0])
    end
  end
end
