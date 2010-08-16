require 'test_helper'

pwd = File.dirname(__FILE__)
f = File.join(pwd, '..', '..', 'app', 'views')
AdminData::MainController.prepend_view_path(f)

class AdminData::MainControllerAuthorizationTest < ActionController::TestCase

  def setup
    @controller = AdminData::MainController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @article = Factory(:article)
    @car = Factory(:car, :year => 2000, :brand => 'bmw')
    grant_read_only_access
    grant_update_access
  end

  #TODO write tests for all before filters
  
  context 'is not allowed to view' do
    setup do
      revoke_read_only_access
      get :table_structure, {:klass => Article.name.underscore}
    end
    should_respond_with(401)
    should 'have text index' do
      assert_tag(:content => 'not authorized')
    end
  end

end

