require 'test/test_helper'

f = File.join(File.dirname(__FILE__),'..','..','app','views')
AdminData::MainController.prepend_view_path(f)
AdminData::DiagnosticController.prepend_view_path(f)

class AdminData::DiagnosticControllerTest < ActionController::TestCase

  def setup
    @controller = AdminData::DiagnosticController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    grant_read_only_access
  end

  should_route :get, '/admin_data/diagnostic',    :controller => 'admin_data/diagnostic',
                                                  :action => :index

  should_route :get, '/admin_data/missing_index', :controller => 'admin_data/diagnostic',
                                                  :action => :missing_index

  context 'before filters' do
    setup do
      @before_filters = @controller.class.before_filter.select do |filter|
        filter.kind_of?(ActionController::Filters::BeforeFilter) 
      end
    end
    context 'ensure_is_allowed_to_view' do
      setup do
        @filter = @before_filters.detect do |filter|
          filter.method == :ensure_is_allowed_to_view
        end
      end
      should 'have filter called ensure_is_allowed_to_view' do
        assert @filter
        assert @filter.options.blank?
      end
    end
  end

  context 'get diagnostic' do
    setup do
      get :index
    end
    should_respond_with :success
    should 'contain text Diagnostic test' do
      assert_tag(:content => 'Diagnostic test')
    end
  end

  context 'get missing_index' do
    setup do
      get :missing_index
    end
    should_respond_with :success
    should 'contain text foreign keys be indexed' do
      assert_tag(:tag => 'p', :content => 'It is recommended that all foreign keys be indexed.')
    end
  end


end
