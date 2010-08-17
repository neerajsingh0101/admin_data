require 'test_helper'

pwd = File.dirname(__FILE__)
f = File.join(pwd, '..', '..', 'app', 'views')
AdminData::MainController.prepend_view_path(f)
AdminData::SearchController.prepend_view_path(f)

class AdminData::SearchControllerTest < ActionController::TestCase

  def setup
    @controller = AdminData::SearchController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @article = Factory(:article)
    grant_read_only_access
  end

  context 'is not allowed to view' do
    setup do
      revoke_read_only_access
      get :quick_search, {:klass => Article.name.underscore}
    end
    should_respond_with(401)
    should 'have text index' do
      assert_tag(:content => 'not authorized')
    end
  end

  context 'is allowed to view klass' do
    context 'negative case' do
      setup do
        _proc = lambda {|controller| controller.instance_variable_get('@klass').name != 'Article' }
        AdminData::Config.set = { :is_allowed_to_view_klass => _proc }
        get :quick_search, {:klass => Article.name.underscore}
      end
      should_respond_with(401)
      should 'have text index' do
        assert_tag(:content => 'not authorized')
      end
    end
    context 'positive case' do
      setup do
        _proc = lambda {|controller| controller.instance_variable_get('@klass').name == 'Article' }
        AdminData::Config.set = { :is_allowed_to_view_klass => _proc }
        get :quick_search, {:klass => Article.name.underscore}
      end
      should_respond_with :success
    end
  end

  context 'is allowed to update' do
    context 'delete operation' do
      setup do
        AdminData::Config.set = { :is_allowed_to_update => lambda {|controller| false } }
        xml_http_request  :post, :advance_search,
        {:klass => Article.name.underscore,
          :sortby => 'article_id desc',
          :admin_data_advance_search_action_type => 'delete',
          :adv_search => {'1_row' => {:col1 => 'short_desc', :col2 => 'contains', :col3 => 'ruby'} } }
      end
      should_respond_with(401)
    end
    context 'destroy operation' do
      setup do
        AdminData::Config.set = { :is_allowed_to_update => lambda {|controller| false } }
        xml_http_request  :post,
          :advance_search,
          {:klass => Article.name.underscore,
            :sortby => 'article_id desc',
            :admin_data_advance_search_action_type => 'destroy',
            :adv_search => {'1_row' => {:col1 => 'short_desc', :col2 => 'contains', :col3 => 'ruby'} } }
      end
      should_respond_with(401)
    end
  end

end
