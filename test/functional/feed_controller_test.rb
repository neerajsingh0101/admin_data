require File.join(File.dirname(__FILE__) , '..', 'test_helper')

f = File.join(File.dirname(__FILE__), '..', '..', 'app', 'views')
AdminData::FeedController.prepend_view_path(f)

class AdminData::FeedControllerTest < ActionController::TestCase

  context 'before filters' do
    setup do
      @before_filters = @controller.class.before_filter.select do |filter|
        filter.kind_of?(ActionController::Filters::BeforeFilter)
      end
    end
    context 'ensure_is_allowed_to_view_feed' do
      setup do
        @filter = @before_filters.detect {|filter| filter.method == :ensure_is_allowed_to_view_feed}
      end
      should 'have filter called ensure_is_allowed_to_view_feed' do
        assert @filter
        assert @filter.options.blank?
      end
    end
  end

  context 'get index' do
    setup do
      Factory(:article)
      get :index, :format => :rss, :klasss => 'article'
    end
    should_respond_with :success
  end

end
