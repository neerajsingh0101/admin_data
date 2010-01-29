require File.join(File.dirname(__FILE__) , '..', 'test_helper')

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

end
