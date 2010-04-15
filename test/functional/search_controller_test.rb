require File.join(File.dirname(__FILE__) ,'..', 'test_helper')

f = File.join(File.dirname(__FILE__),'..','..','app','views')
AdminData::MainController.prepend_view_path(f)
AdminData::SearchController.prepend_view_path(f)

class AdminData::SearchControllerTest < ActionController::TestCase

  def setup
    @controller = AdminData::SearchController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @article = Factory(:article)
    @car = Factory(:car, :year => 2000, :brand => 'bmw')
    grant_read_only_access
  end

  should_route :get, '/admin_data/quick_search/article', :controller => 'admin_data/search', :action => :quick_search, :klass => 'article'

  should_route :get, '/admin_data/advance_search/article', :controller => 'admin_data/search', :action => :advance_search, :klass => 'article'

  context 'filters list' do
    setup do
      @before_filters = @controller.class.before_filter.select do |filter|
        filter.kind_of?(ActionController::Filters::BeforeFilter)
      end
    end
    context 'for ensure_is_allowed_to_view filter' do
      setup do
        @filter = @before_filters.detect {|filter| filter.method == :ensure_is_allowed_to_view }
      end
      should 'have filter called ensure_is_allowed_to_view' do
        assert @filter
      end
      should 'have no options for the filter' do
        assert @filter.options.blank?
      end
    end
    context 'for ensure_is_allowed_to_view_model filter' do
      setup do
        @filter = @before_filters.detect {|filter| filter.method == :ensure_is_allowed_to_view_model }
      end
      should 'have filter called ensure_is_allowed_to_view_model' do
        assert @filter
      end
      should 'have no option for filter' do
        assert @filter.options.blank?
      end
    end
  end

  context 'GET quick_search' do
    context 'GET quick_search with wrong children class' do
      setup do
        get :quick_search, { :base => 'article', :klass => 'comment', :model_id => @article.id, :children => 'wrong_children_name' }
      end
      should_respond_with :not_found
    end

    context 'with no klass param' do
      setup do
        assert_raises ActionController::RoutingError do
          get :quick_search
        end
      end
    end

    context 'with no search query' do
      setup do
        get :quick_search, {:klass => Article.name.underscore}
      end
      should_respond_with :success
      should_assign_to :records
    end
    context 'with has_many association' do
      context 'for a nested model' do
        setup do
          Vehicle::Door.delete_all
          @door1 = Factory(:door, :color => 'black', :car => @car)
          @door2 = Factory(:door, :color => 'green', :car => @car)
          get :quick_search, {  :klass => @door1.class.name.underscore, :base => @car.class.name.underscore, :model_id => @car.id, :children => 'doors'}
        end
        should_respond_with :success
        should_assign_to :records
        should 'have 2 records' do
          assert_equal 2, assigns(:records).size
        end
        should 'have 2 as total number of children' do
          assert_equal 2, assigns(:total_num_of_children)
        end
        should 'contain text' do
          assert_tag(:tag => 'h2', :attributes => {:class => 'title'}, :content => /has 2/m)
        end
      end

      context 'for a standard model' do
        setup do
          @comment1 = Factory(:comment, :article => @article)
          @comment2 = Factory(:comment, :article => @article)
          get :quick_search, { :klass => Comment.name.underscore, :base => 'article', :model_id => @article.id, :children => 'comments' }
        end
        should_respond_with :success
        should_assign_to :records
        should 'have 2 records' do
          assert_equal 2, assigns(:records).size
        end
        should 'contain text' do
          assert_tag(:tag => 'h2', :attributes => {:class => 'title'}, :content => /has 2 comments/ )
        end
      end
    end
  end


  context 'GET quick_search' do
    context 'for a standard model' do
      setup do
        @comment = Factory(:comment)
        @comment = Factory(:comment)
        get :quick_search, {:klass => @comment.class.name.underscore}
      end
      should_respond_with :success
      should 'contain valid link at header breadcrum' do
        assert_tag( :tag => 'div', :attributes => {:class => 'breadcrum rounded'}, :descendant => {:tag => 'a', :attributes => {:href => '/admin_data/quick_search/comment'}})
      end
      should 'contain proper link at table listing' do
        url = "/admin_data/klass/comment/#{Comment.last.id}"
        assert_tag( :tag => 'td', :descendant => {:tag => 'a', :attributes => {:href => url}})
      end
    end

    context 'for a nested model' do
      setup do
        get :quick_search, {:klass => @car.class.name.underscore}
      end
      should_respond_with :success
      should 'contain proper link at header breadcum' do
        s = CGI.escape('vehicle/car')
        assert_tag(:tag => 'div', :attributes => {:class => 'breadcrum rounded'}, :descendant => {:tag => 'a', :attributes => {:href => "/admin_data/quick_search/#{s}" }})
      end
      should 'contain proper link at table listing' do
        s = CGI.escape("vehicle/car")
        url = "/admin_data/klass/#{s}/#{@car.class.last.id}"
        assert_tag(:tag => 'td', :descendant => {:tag => 'a', :attributes => {:href => url}})
      end
      should 'have proper action name for search form' do
        url = admin_data_search_path(:klass=>Vehicle::Car)
        assert_tag( :tag => 'form', :attributes => {:action => url})
      end
    end
  end

  context 'GET quick_search with search term' do
    setup do
      Article.delete_all
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      @python_book = Factory(:article, :title => 'python')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure')
    end
    context 'with default order' do
      setup do
        get :quick_search, {:klass => 'Article', :query => 'python'}
      end
      should_respond_with :success
      should_assign_to :records
      should 'have only two records' do
        assert_equal 2, assigns(:records).size
      end
      should 'have python beginner book as the first book' do
        assert_equal @python_beginner_book.id, assigns(:records).last.id
      end
      should 'have python book as the last book' do
        assert_equal @python_book.id, assigns(:records).first.id
      end
    end

    context 'with article_id ascending order' do
      setup do
        get :quick_search, { :klass => 'Article', :query => 'python', :sortby => 'article_id asc'}
      end
      should_respond_with :success
      should_assign_to :records
      should 'have only two records' do
        assert_equal 2, assigns(:records).size
      end
      should 'have python beginner book as the first book' do
        assert_equal @python_beginner_book.id, assigns(:records).first.id
      end
      should 'have python book as the last book' do
        assert_equal @python_book.id, assigns(:records).last.id
      end
    end
  end

  context 'GET advance_search' do
    context 'with no klass param' do
      setup do
        assert_raises ActionController::RoutingError do
          get :advance_search
        end
      end
    end

    context 'with klass param' do
      setup do
        get :advance_search, {:klass => Article.name.underscore}
      end
      should_respond_with :success
      should_not_assign_to :records
      should 'have proper action for advance search form' do
        url = admin_data_advance_search_path(:klass => Article)
        assert_tag( :tag => 'form', :attributes => {:action => url})
      end
    end
  end


  context 'xhr advance_search with does_not_contain first one' do
    setup do
      Article.delete_all
      AdminDataConfig.set = ({ :is_allowed_to_update => lambda {|controller| return false} })
      Factory(:article, :short_desc => 'ruby')
      Factory(:article, :short_desc => 'rails')
      Factory(:article, :short_desc => nil)
      xml_http_request  :post, :advance_search, {:klass => Article.name.underscore, :sortby => 'article_id desc', :adv_search => {'1_row' => {:col1 => 'short_desc', :col2 => 'does_not_contain', :col3 => 'ruby'} } }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'h2', :attributes => {:class => 'title'}, :content => /Search result: 2 records found/ )
    end
    should 'not contain delete all link' do
      assert_no_tag( :tag => 'a', :attributes => {:id => 'advance_search_delete_all'})
    end
    should 'not contain destroy all link' do
      assert_no_tag( :tag => 'a', :attributes => {:id => 'advance_search_destroy_all'})
    end
  end

  context 'xhr advance_search with delete_all action' do
    setup do
      Article.delete_all
      AdminDataConfig.set = ({ :is_allowed_to_update => lambda {|controller| return true} })
      Factory(:article, :short_desc => 'ruby')
      Factory(:article, :short_desc => 'rails')
      so   = {'1_row' => {:col1 => 'short_desc', :col2 => 'contains', :col3 => 'ruby'} }
      h = { :klass => Article.name.underscore,
        :sortby => 'article_id desc',
      :admin_data_advance_search_action_type => 'delete', :adv_search => so }
      xml_http_request  :post, :advance_search, h
      @json = JSON.parse(@response.body)
    end
    should_respond_with :success
    should 'have only one record' do
      assert_equal 1, Article.count
    end
    should 'have success key in the response message' do
      assert @json.has_key?('success')
    end
    should 'have success message in the response message' do
      assert_equal @json.fetch('success'), '1 record deleted'
    end
  end

  context 'xhr advance_search with destroy_all action' do
    setup do
      Article.delete_all
      AdminDataConfig.set = ({ :is_allowed_to_update => lambda {|controller| return true} })
      Factory(:article, :short_desc => 'ruby')
      Factory(:article, :short_desc => 'rails')
      xml_http_request  :post,
      :advance_search, {:klass => Article.name.underscore, :sortby => 'article_id desc', :admin_data_advance_search_action_type => 'destroy', :adv_search => {'1_row' => {:col1 => 'short_desc', :col2 => 'contains', :col3 => 'ruby'} } }
      @json = JSON.parse(@response.body)
    end
    should_respond_with :success
    should 'have only one record' do
      assert_equal 1, Article.count
    end
    should 'have success key in the response message' do
      assert @json.has_key?('success')
    end
    should 'have success message in the response message' do
      assert_equal @json.fetch('success'), '1 record destroyed'
    end
  end

  context 'xhr advance_search with does_not_contain' do
    setup do
      AdminDataConfig.set = ({ :is_allowed_to_update => lambda {|controller| return true } })
      Article.delete_all
      Factory(:article, :short_desc => 'ruby')
      Factory(:article, :short_desc => 'rails')
      Factory(:article, :short_desc => nil)
      xml_http_request  :post, :advance_search, {:klass => Article.name.underscore, :sortby => 'article_id desc', :adv_search => {'1_row' => {:col1 => 'short_desc', :col2 => 'does_not_contain', :col3 => 'ruby'} } }
    end
    should_respond_with :success
    should 'contain search result' do
      assert_tag(:tag => 'h2', :attributes => {:class => 'title'}, :content => /Search result: 2 records found/ )
    end
    should 'contain delete all link' do
      assert_tag( :tag => 'a', :attributes => {:id => 'advance_search_delete_all'})
    end
    should 'contain destroy all link' do
      assert_tag( :tag => 'a', :attributes => {:id => 'advance_search_destroy_all'})
    end
  end

  context 'xhr advance_search with contains option with 2 records' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure')
      xml_http_request  :post, :advance_search, {:klass => Article.name.underscore, :sortby => 'article_id desc', :adv_search => {'1_row' => {:col1 => 'title', :col2 => 'contains', :col3 => 'python'} } }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'h2', :attributes => {:class => 'title'}, :content => /Search result: 2 records found/ )
    end
  end

  context 'xhr advance_search with 1 result' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure')
      xml_http_request  :post, :advance_search, { :klass => Article.name.underscore, :sortby => 'article_id desc', :adv_search => {'1_row' => {:col1 => 'title', :col2 => 'contains', :col3 => 'clojure'} } }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'h2', :attributes => {:class => 'title'}, :content => /Search result: 1 record found/ )
    end
  end

  context 'xhr advance_search with empty query term with contains option' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure')
      xml_http_request  :post, :advance_search, { :klass => Article.name.underscore, :sortby => 'article_id desc', :adv_search => {'1_row' => {:col1 => 'title', :col2 => 'contains', :col3 => ''} } }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'h2', :attributes => {:class => 'title'}, :content => /Search result: 4 records found/ )
    end
  end

  context 'xhr advance_search with empty col2' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      xml_http_request  :post, :advance_search, { :klass => Article.name.underscore, :sortby => 'article_id desc', :adv_search => {'1_row' => {:col1 => 'title', :col2 => nil, :col3 => nil} } }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'h2', :attributes => {:class => 'title'}, :content => /Search result: 2 records found/ )
    end
  end

  context 'xhr advance_search with two search terms' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners',
      :body => 'for beginners')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure', :body => 'not for beginners')
      adv_search = { '1_row' => {:col1 => 'title', :col2 => 'contains', :col3 => 'python'}, '2_row' => {:col1 => 'body', :col2 => 'contains', :col3 => 'beginners'} }
      xml_http_request  :post, :advance_search, { :klass => Article.name.underscore, :sortby => 'article_id desc', :adv_search => adv_search }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'h2', :attributes => {:class => 'title'}, :content => /Search result: 1 record found/ )
    end
  end

  context 'advance search conditions' do
    setup do
      @klass = Object.const_get('Article')
      @proc = Proc.new do
        @controller.send(:build_advance_search_conditions, @klass, { '429440_row' => @hash })
      end
    end

    context 'with col2 as null' do
      should 'have sql as body is not null' do
        @hash = { :col1 => 'body', :col2 => 'is_not_null'}
        output = @proc.call
        assert_equal '(articles.body IS NOT NULL)', output[:cond]
      end
    end

    context 'with col2 contains' do
      should 'have sql with like' do
        @hash = { :col1 => 'body', :col2 => 'contains', :col3 => 'python'}
        output = @proc.call
        assert_equal "(articles.body LIKE '%python%')", output[:cond]
      end
    end

    context 'with col2 as exactly' do
      should 'have sql as body equals' do
        @hash = { :col1 => 'body', :col2 => 'is_exactly', :col3 => 'python'}
        output = @proc.call
        assert_equal "(articles.body = 'python')", output[:cond]
      end
    end

    context 'with does not contain' do
      should 'have sql as body is null or not like' do
        @hash = { :col1 => 'body', :col2 => 'does_not_contain', :col3 => 'python'}
        output = @proc.call
        assert_equal "(articles.body IS NULL OR articles.body NOT LIKE '%python%')", output[:cond]
      end
    end

    context 'with col2 as false' do
      should 'have sql with body as false' do
        @hash = { :col1 => 'body', :col2 => 'is_false', :col3 => 'python'}
        output = @proc.call
        assert_equal "(articles.body = 'f')", output[:cond]
      end
    end
  end


  context 'XHR advance_search' do
    setup do
      Article.delete_all
      @proc = Proc.new do
        @hash_big = { :klass => Article.name.underscore, :adv_search => {'2_row' => @hash } }
      end
    end
    context 'with col2 contains' do
      setup do
        Factory(:article, :title => 'python')
        @hash = {:col1 => 'title', :col2 => 'contains', :col3 => 'python'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should_respond_with :success
      should 'contain content' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title'}, :content => /Search result: 1 record found/ )
      end
    end

    context 'with col2 contains with no search result' do
      setup do
        Factory(:article, :title => 'ruby')
        @hash = { :col1 => 'title', :col2 => 'contains', :col3 => 'python'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title' }, :content => /Search result: 0 records found/ )
      end
    end

    context 'with col2 is_exactly' do
      setup do
        Factory(:article, :title => 'python')
        @hash = { :col1 => 'title', :col2 => 'is_exactly', :col3 => 'python'}
        xml_http_request :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title'}, :content => /Search result: 1 record found/ )
      end
    end

    context 'with col2 is_exactly negative case' do
      setup do
        Factory(:article, :title => 'ruby')
        @hash = {:col1 => 'title', :col2 => 'is_exactly', :col3 => 'python'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :id => 'search_result_title'}, :content => /Search result: 0 records found/ )
      end
    end

    context 'with col2 does_not_contain' do
      setup do
        Factory(:article, :title => 'python')
        @hash = {:col1 => 'title', :col2 => 'does_not_contain', :col3 => 'ruby'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title'}, :content => /Search result: 1 record found/ )
      end
    end

    context 'with col2 does_not_conatin negative case' do
      setup do
        Factory(:article, :title => 'ruby')
        @hash = {:col1 => 'title', :col2 => 'does_not_contain', :col3 => 'ruby'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes =>{ :class => 'title'}, :content => /Search result: 0 records found/ )
      end
    end

    context 'with col2 is_false' do
      setup do
        Factory(:article, :approved => false)
        @hash = {:col1 => 'approved', :col2 => 'is_false'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => {:class => 'title'}, :content => /Search result: 1 record found/ )
      end
    end

    context 'with col2 is_false negative case' do
      setup do
        Factory(:article, :approved => true)
        @hash = {:col1 => 'approved', :col2 => 'is_false'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag(:tag => 'h2', :attributes => {:class => 'title'}, :content => /Search result: 0 records found/ )
      end
    end

    context 'with col2 is_true' do
      setup do
        Factory(:article, :approved => true)
        @hash = {:col1 => 'approved', :col2 => 'is_true'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title'}, :content => /Search result: 1 record found/ )
      end
    end

    context 'with col2 is_true negative case' do
      setup do
        Factory(:article, :approved => false)
        @hash = {:col1 => 'approved', :col2 => 'is_true'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag(:tag => 'h2', :attributes => {:class => 'title'}, :content => /Search result: 0 records found/ )
      end
    end

    context 'with col2 is_null' do
      setup do
        Factory(:article, :status => nil)
        @hash = {:col1 => 'status', :col2 => 'is_null'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title' }, :content => /Search result: 1 record found/ )
      end
    end

    context 'with col2 is_null negative case' do
      setup do
        Factory(:article, :status => 'something')
        @hash = {:col1 => 'status', :col2 => 'is_null'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag(:tag => 'h2', :attributes => {:class => 'title'}, :content => /Search result: 0 records found/ )
      end
    end

    context 'with col2 is_not_null' do
      setup do
        Factory(:article, :status => 'something')
        @hash = {:col1 => 'status', :col2 => 'is_not_null'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title'}, :content => /Search result: 1 record found/ )
      end
    end

    context 'with col2 is_not_null negative case' do
      setup do
        Factory(:article, :status => nil)
        @hash = {:col1 => 'status', :col2 => 'is_not_null'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title'}, :content => /Search result: 0 records found/ )
      end
    end

    context 'with col2 is_equal_to' do
      setup do
        Factory(:article, :hits_count => 100)
        @hash = {:col1 => 'hits_count', :col2 => 'is_equal_to', :col3 => 100.to_s}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title' }, :content => /Search result: 1 record found/ )
      end
    end

    context 'with col2 is_equal_to negative case' do
      setup do
        Factory(:article, :hits_count => 100)
        @hash = {:col1 => 'hits_count', :col2 => 'is_equal_to', :col3 => 101.to_s}
        xml_http_request :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title' }, :content => /Search result: 0 records found/ )
      end
    end

    context 'with col2 greater_than' do
      setup do
        Factory(:article, :hits_count => 100)
        @hash = {:col1 => 'hits_count', :col2 => 'greater_than', :col3 => 99.to_s}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title'}, :content => /Search result: 1 record found/ )
      end
    end

    context 'with col2 greater_than negative case' do
      setup do
        Factory(:article, :hits_count => 100)
        @hash = {:col1 => 'hits_count', :col2 => 'greater_than', :col3 => 101.to_s}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title'}, :content => /Search result: 0 records found/ )
      end
    end

    context 'with col2 less_than' do
      setup do
        Factory(:article, :hits_count => 100)
        @hash = {:col1 => 'hits_count', :col2 => 'less_than', :col3 => 101.to_s}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title' }, :content => /Search result: 1 record found/ )
      end
    end

    context 'with col2 less_than negative case' do
      setup do
        Factory(:article, :hits_count => 100)
        @hash = {:col1 => 'hits_count', :col2 => 'less_than', :col3 => 99.to_s}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title' }, :content => /Search result: 0 records found/ )
      end
    end

    context 'with col2 is_on' do
      setup do
        Factory(:article, :published_at => Time.now)
        d = Time.now.strftime('%d-%B-%Y')
        @hash = {:col1 => 'published_at', :col2 => 'is_on', :col3 => d}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes =>{ :class => 'title'}, :content => /Search result: 1 record found/ )
      end
    end

    context 'with col2 is_on negative case' do
      setup do
        Factory(:article, :published_at => Time.now)
        d = 1.year.ago.strftime('%d-%B-%Y')
        @hash = {:col1 => 'published_at', :col2 => 'is_on', :col3 => d}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title'}, :content => /Search result: 0 records found/ )
      end
    end

    context 'with col2 is_on_or_after_date' do
      setup do
        Factory(:article, :published_at => Time.now)
        @hash = {:col1 => 'published_at', :col2 => 'is_on_or_after_date', :col3 => 1.month.ago.strftime('%d-%B-%Y') }
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title'}, :descendant => /Search result: 1 record found/ )
      end
    end

    context 'with col2 is_on_or_after_date negative case' do
      setup do
        Factory(:article, :published_at => Time.now)
        @hash = {:col1 => 'published_at', :col2 => 'is_on_or_after_date', :col3 => 1.month.from_now.strftime('%d-%B-%Y') }
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title' }, :content => /Search result: 0 records found/ )
      end
    end

    context 'with col2 is_on_or_before_date' do
      setup do
        Factory(:article, :published_at => Time.now)
        @hash = {:col1 => 'published_at', :col2 => 'is_on_or_before_date', :col3 => 1.month.from_now.strftime('%d-%B-%Y') }
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag( :tag => 'h2', :attributes => { :class => 'title'}, :content => /Search result: 1 record found/ )
      end
    end

    context 'with col2 is_on_or_before_date negative case' do
      setup do
        @hash = {:col1 => 'published_at', :col2 => 'is_on_or_before_date', :col3 => 1.year.ago.strftime('%d-%B-%Y') }
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'does contain text' do
        assert_tag(:tag => 'h2', :attributes => {:class => 'title'}, :content => /Search result: 0 records found/ )
      end
    end

    context 'with col2 is_on_or_before_date with invalid_date input' do
      setup do
        @hash = {:col1 => 'published_at', :col2 => 'is_on_or_before_date', :col3 => 'invalid_date'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag(:tag => 'p', :attributes => {:class => 'error'}, :content => /is not a valid date/ )
      end
    end

    context 'with col2 is_on_or_after_date with invalid_date input' do
      setup do
        @hash = {:col1 => 'published_at', :col2 => 'is_on_or_after_date', :col3 => 'invalid_date'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag(:tag => 'p', :attributes => {:class => 'error'}, :content => /is not a valid date/ )
      end
    end

    context 'is_on invalid date' do
      setup do
        @hash = {:col1 => 'published_at', :col2 => 'is_on', :col3 => 'invalid_date'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag(:tag => 'p', :attributes => {:class => 'error'}, :content => /is not a valid date/ )
      end
    end

    context 'with col2 is_equal_to with invalid input' do
      setup do
        @hash = {:col1 => 'hits_count', :col2 => 'is_equal_to', :col3 => 'invalid_integer'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag(:tag => 'p', :attributes => {:class => 'error'}, :content => /is not a valid integer/ )
      end
    end

    context 'with col2 less_than invalid_integer' do
      setup do
        @hash = {:col1 => 'hits_count', :col2 => 'less_than', :col3 => 'invalid_integer'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag(:tag => 'p', :attributes => {:class => 'error'}, :content => /is not a valid integer/ )
      end
    end

    context 'with col2 greater_than invalid integer' do
      setup do
        @hash = {:col1 => 'hits_count', :col2 => 'greater_than', :col3 => 'invalid_integer'}
        xml_http_request  :post, :advance_search, @proc.call
      end
      should 'contain text' do
        assert_tag(:tag => 'p', :attributes => {:class => 'error'}, :content => /is not a valid integer/ )
      end
    end

  end

end
