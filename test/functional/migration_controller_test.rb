pwd = File.dirname(__FILE__)
require File.join(pwd, '..', 'test_helper')

f = File.join(pwd, '..', '..', 'app', 'views')
AdminData::MainController.prepend_view_path(f)
AdminData::MigrationController.prepend_view_path(f)

class AdminData::MigrationControllerTest < ActionController::TestCase

  def setup
    @controller = AdminData::MigrationController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  context 'authorization check' do
    setup do
      revoke_read_only_access
      get :index
    end
    should_respond_with(401)
    should 'have text index' do 
      assert_tag(:content => 'not authorized') 
    end
  end

  context 'GET index' do
    setup do
      grant_read_only_access
      get :index
    end
    should_respond_with :success
    should_assign_to :data
    should 'contain title' do
      assert_tag(:tag => 'h2', :content => 'Migration Information from schema_migrations table')
    end
  end

end
