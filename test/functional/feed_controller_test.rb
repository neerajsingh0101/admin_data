pwd = File.dirname(__FILE__)
require File.join(pwd, '..', 'test_helper')

f = File.join(pwd, '..', '..', 'app', 'views')
AdminData::FeedController.prepend_view_path(f)

#TODO mention this dependency in gemspec
require 'nokogiri'

class AdminData::FeedControllerTest < ActionController::TestCase

  #TODO write a test to check before_filter authorization. Testing will be a bit tricky since
  #http_basic_authentication is done
  context 'GET index' do
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
      assert Regexp.new("/admin_data/klass/Article/#{@article.id}-").match(guid)
    end
  end

end
