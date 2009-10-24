require 'test/test_helper'

class ArticlesControllerTest < ActionController::TestCase

  def setup
    @controller = ArticlesController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @article = Article.first
  end

  should_route :get, '/articles',     :action => :index
  should_route :post, '/articles',     :action => :create

end
