require File.join(File.dirname(__FILE__) ,'..', 'test_helper')

f = File.join(File.dirname(__FILE__),'..','..','app','views')
AdminData::MainController.prepend_view_path(f)
AdminData::MigrationController.prepend_view_path(f)

class AdminData::MigrationControllerTest < ActionController::TestCase

  def setup
    @controller = AdminData::MigrationController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    grant_read_only_access
  end

  should_route :get, '/admin_data/migration',    :controller => 'admin_data/migration',
                                                  :action => :index

  context 'get index' do
    setup do
      get :index
    end
    should_respond_with :success
    should_assign_to :data
    should 'contain title' do
      assert_tag(:tag => 'h2', :content => 'Migration Information from schema_migrations table')
    end
  end

end
