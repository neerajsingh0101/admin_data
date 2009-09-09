require File.join(File.dirname(__FILE__) ,'..', 'test_helper')

class AdminData::BaseControllerTest < ActionController::TestCase

  context 'testing filter ensure_is_allowed_to_view' do
    setup do
      AdminData::BaseController.before_filter.each do |filter|
        if filter.kind_of?(ActionController::Filters::BeforeFilter) && filter.method == :ensure_is_allowed_to_view
         @filter = filter 
        end
      end
    end
    should 'have filter called ensure_is_allowed_to_view' do
      assert @filter
      assert @filter.options.blank?
    end
  end

end
