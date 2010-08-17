require 'test_helper'

pwd = File.dirname(__FILE__)
f = File.join(pwd, '..', '..', 'app', 'views')
AdminData::FeedController.prepend_view_path(f)

require 'nokogiri'

class AdminData::FeedControllerTest < ActionController::TestCase

  context 'authorization' do
    context 'failure' do
      setup do
        AdminData::Config.set = { :feed_authentication_user_id => 'hello', :feed_authentication_password => 'world' }
        @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('bad_userid', 'bad_password')
        get :index, :format => :rss, :klasss => 'article',
        'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('bad_user', 'bad_password')
      end
      should_respond_with(401)
    end
  end


  context 'GET index' do
    setup do
      AdminData::Config.set = { :feed_authentication_user_id => 'hello', :feed_authentication_password => 'world' }
      @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('hello', 'world')
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
