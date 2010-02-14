require File.join(File.dirname(__FILE__) , '..', 'test_helper')

f = File.join(File.dirname(__FILE__), '..', '..', 'app', 'views')
AdminData::ValidateModelController.prepend_view_path(f)

class AdminData::ValidateModelControllerTest < ActionController::TestCase

  def setup
    @controller = AdminData::ValidateModelController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  should_route :get, '/admin_data/diagnostic/validate', :controller => 'admin_data/validate_model', :action => :validate

  should_route :get, '/admin_data/diagnostic/validate_model', :controller => 'admin_data/validate_model', :action => :validate_model

  context 'filters list' do
    setup do
      @before_filters = @controller.class.before_filter.select do |filter|
        filter.kind_of?(ActionController::Filters::BeforeFilter)
      end
      @filter = @before_filters.detect {|filter| filter.method == :ensure_is_allowed_to_view }
    end
    should 'have filter called ensure_is_allowed_to_view' do
      assert @filter
    end
    should 'have no option for the filter' do
      assert @filter.options.blank?
    end
  end

  context 'GET validate' do
    setup do
      get :validate
    end
    should_respond_with :success
  end

  context 'POST validate params[:tid] missing case' do
    context 'with params[:tid] missing' do
      setup do
        xml_http_request :post, :validate_model
        @json = JSON.parse(@response.body)
      end
      should_respond_with :success
      should 'output should have error key' do
        assert @json.has_key?('error')
      end
      should 'output should have error message' do
        assert_equal 'Something went wrong. Please try again !!', @json.fetch('error')
      end
    end

    context 'with params[:model] missing' do
      setup do
        tid = Time.now.strftime('%Y%m%d%H%M%S')
        xml_http_request :post, :validate_model, :tid => tid
        @json = JSON.parse(@response.body)
      end
      should_respond_with :success
      should 'output should have error key' do
        assert @json.has_key?('error')
      end
      should 'output should have error message' do
        assert 'Please select at least one model', @json.fetch('error')
      end
    end
  end

end
