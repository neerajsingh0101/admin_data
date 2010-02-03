require File.join(File.dirname(__FILE__) , '..', 'test_helper')
require 'nokogiri'

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
      Article.delete_all
      @article = Factory(:article)
      get :index, :format => :rss, :klasss => 'article'
      @feed = Nokogiri::XML(@response.body)
    end
    should_respond_with :success
    should 'have RSS feed 2.0' do
      assert_equal '2.0', @feed.at('rss')['version']
    end
    should 'have title' do
      assert_equal "Feeds from admin_data Article id: #{@article.id}", @feed.css('channel title').text
    end
    should 'have guid' do
      guid = @feed.css('channel item guid').text
      r  = Regexp.new "/admin_data/klass/Article/#{@article.id}-"
      assert r.match(guid) 
    end
  end

end
