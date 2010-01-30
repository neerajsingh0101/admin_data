require File.join(File.dirname(__FILE__) , '..', 'test_helper')

f = File.join(File.dirname(__FILE__), '..', '..', 'app', 'views')
AdminData::ValidateModelController.prepend_view_path(f)

class AdminData::ValidateModelControllerTest < ActionController::TestCase
   
  def setup
    @controller = AdminData::ValidateModelController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  should_route :get, '/admin_data/diagnostic/validate',  
                                                   :controller => 'admin_data/validate_model',
                                                   :action => :validate

  should_route :get, '/admin_data/diagnostic/validate_model',  
                                                   :controller => 'admin_data/validate_model',
                                                   :action => :validate_model

  context 'before filters' do
    setup do
      @before_filters = @controller.class.before_filter.select do |filter|
        filter.kind_of?(ActionController::Filters::BeforeFilter) 
      end
    end
    context 'ensure_is_allowed_to_view' do
      setup do
        @filter = @before_filters.detect {|filter| filter.method == :ensure_is_allowed_to_view }
      end
      should 'have filter called ensure_is_allowed_to_view' do
        assert @filter
        assert @filter.options.blank?
      end
    end
  end

  context 'get validate' do
   setup do
      get :validate
   end
   should_respond_with :success
  end

  context 'params[:tid] missing case' do
     setup do
         xml_http_request :post, :validate_model 
     end
     should_respond_with :success
     should 'testing JSON output' do
        o = JSON.parse(@response.body)
        assert o.has_key?('error')
        assert o.fetch('error') == 'Something went wrong. Please try again !!'
     end
  end

  context 'params[:model] missing case' do
     setup do
         tid = Time.now.strftime('%Y%m%d%H%M%S')
         xml_http_request :post, :validate_model, :tid => tid 
     end
     should_respond_with :success
     should 'testing JSON output' do
        o = JSON.parse(@response.body)
        assert o.has_key?('error')
        assert o.fetch('error') == 'Please select at least one model' 
     end
  end

  
#model[Car]	1
#http://localhost:3000/admin_data/diagnostic/validate
#tid	20100129173138
#still_processing	yes
  
end
