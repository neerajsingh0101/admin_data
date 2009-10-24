require 'test/test_helper'

f = File.join(File.dirname(__FILE__),'..','..','app','views')
AdminData::MainController.prepend_view_path(f)
AdminData::SearchController.prepend_view_path(f)

class AdminData::SearchControllerTest < ActionController::TestCase

  def setup
    @controller = AdminData::SearchController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @article = Factory(:article)
    @car = Vehicle::Car.create(:year => 2000, :brand => 'bmw')
    grant_read_only_access
  end

  should_route :get, '/admin_data/article/search',  :controller => 'admin_data/search',
                                                    :action => :search,
                                                    :klass => 'article'

  should_route :get, '/admin_data/article/advance_search',  
                                                    :controller => 'admin_data/search',
                                                    :action => :advance_search,
                                                    :klass => 'article'

  context 'get search car has_many association' do
    setup do
      Vehicle::Door.delete_all
      @door1 = Vehicle::Door.create(:color => 'black', :car_id => @car.id) 
      @door2 = Vehicle::Door.create(:color => 'green', :car_id => @car.id) 
      get :search, {  :base => @car.class.name.underscore, 
                      :klass => @door1.class.name.underscore, 
                      :id => @car.id, 
                      :children => 'doors'}
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
      assert_tag(:tag => 'h2', 
                 :attributes => {:class => 'title'}, 
                 :content => /has 2/m)
    end
  end

  context 'get search article has_many association' do
    setup do
      @comment1 = Factory(:comment, :article => @article)
      @comment2 = Factory(:comment, :article => @article)
      get :search, { :base => 'article',  :klass => Comment.name.underscore, 
                                          :id => @article.id, 
                                          :children => 'comments' }
    end
    should_respond_with :success
    should_assign_to :records
    should 'have 2 records' do
      assert_equal 2, assigns(:records).size
    end
    should 'contain text' do
      assert_tag(:tag => 'h2', 
                 :attributes => {:class => 'title'}, 
                 :content => /has 2 comments/ )
    end
  end

  context 'get search for children but children class is wrong' do
    setup do
      get :search, { :base => 'article',  :klass => 'comment', 
                                          :model_id => @article.id, 
                                          :children => 'wrong_children_name' }
    end
    should_respond_with :not_found
  end

  
  context 'get search for comment' do
    setup do
      @comment = Factory(:comment)
      @comment = Factory(:comment)
      get :search, {:klass => @comment.class.name.underscore}
    end
    should_respond_with :success
    should 'contain valid link at header breadcrum' do
      assert_tag( :tag => 'div',
                  :attributes => {:class => 'breadcrum'},
                  :descendant => {:tag => 'a', 
                                  :attributes => {:href => '/admin_data/comment/search'}})
    end
    should 'contain proper link at table listing' do
      url = "/admin_data/comment/#{Comment.last.id}"
      assert_tag( :tag => 'td', :descendant => {:tag => 'a', 
                                                :attributes => {:href => url}})
    end
  end

  context 'get search for car' do
    setup do
      get :search, {:klass => @car.class.name.underscore}
    end
    should_respond_with :success
    should 'contain proper link at header breadcum' do
       s = CGI.escape('vehicle/car')
       assert_tag(:tag => 'div', 
                  :attributes => {:class => 'breadcrum'},
                  :descendant => {:tag => 'a', 
                                  :attributes => {:href => "/admin_data/#{s}/search" }})
    end
    should 'contain proper link at table listing' do
       s = CGI.escape("vehicle/car")
       url = "/admin_data/#{s}/#{@car.class.last.id}"
       assert_tag(:tag => 'td',
                  :descendant => {:tag => 'a', :attributes => {:href => url}})
    end
    should 'have proper action name for search form' do
      url = "/admin_data/vehicle/car/search"
      assert_tag( :tag => 'form',
                  :attributes => {:action => url})
    end
  end

  context 'get search with no klass param' do
    setup do
      assert_raises ActionController::RoutingError do
        get :search
      end
    end
  end

  context 'get search with no search query' do
    setup do
      get :search, {:klass => Article.name.underscore}
    end
    should_respond_with :success
    should_assign_to :records
  end

  context 'get search with search query default order' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure')
      get :search, {:klass => 'Article', :query => 'python'}
    end
    should_respond_with :success
    should_assign_to :records
    should 'have only one record' do
      assert_equal 2, assigns(:records).size
      assert_equal @python_book.id, assigns(:records).last.id
      assert_equal @python_beginner_book.id, assigns(:records).first.id
    end
  end

  context 'get search with search term with revert id order' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure')
      get :search, {:klass => 'Article',  :query => 'python', 
                                          :sortby => 'article_id desc'}
    end
    should_respond_with :success
    should_assign_to :records
    should 'have only one record' do
      assert_equal 2, assigns(:records).size
      assert_equal @python_book.id, assigns(:records).last.id
      assert_equal @python_beginner_book.id, assigns(:records).first.id
    end
  end
 
  context 'get advance_search with no klass param' do
    setup do
      assert_raises ActionController::RoutingError do 
        get :advance_search
      end
    end
  end

  context 'get advance_search with klass param' do
    setup do
      get :advance_search, {:klass => Article.name.underscore}
    end
    should_respond_with :success
    should_assign_to :records
    should 'have proper action for advance search form' do
      url = "/admin_data/article/advance_search"
      assert_tag( :tag => 'form',
                  :attributes => {:action => url})
    end
  end

  context 'xhr advance_search with 2 results' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure')
      xml_http_request  :post,
                        :advance_search, {:klass => Article.name.underscore, 
                                          :sortby => 'article_id desc',
                                          :adv_search => {'1_row' => {:col1 => 'title', 
                                                                      :col2 => 'contains', 
                                                                      :col3 => 'python'} }
                            }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'h2', 
                 :attributes => {:class => 'title'}, 
                 :content => /Search result: 2 records found/ )
    end
  end

  context 'xhr advance_search with 1 result' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure')
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :sortby => 'article_id desc',
                          :adv_search => {'1_row' => {:col1 => 'title', 
                                                      :col2 => 'contains', 
                                                      :col3 => 'clojure'} }
                        }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'h2', 
                 :attributes => {:class => 'title'}, 
                 :content => /Search result: 1 record found/ )
    end
  end

  context 'xhr advance_search with empty query term' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure')
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :sortby => 'article_id desc',
                          :adv_search => {'1_row' => {:col1 => 'title', 
                                                      :col2 => 'contains', 
                                                      :col3 => ''} }
                        }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'h2', 
                 :attributes => {:class => 'title'}, 
                 :content => /Search result: 4 records found/ )
    end
  end


  context 'xhr advance_search with empty col2' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :sortby => 'article_id desc',
                          :adv_search => {'1_row' => {:col1 => 'title', 
                                                      :col2 => nil, 
                                                      :col3 => nil} }
                        }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'h2', 
                 :attributes => {:class => 'title'}, 
                 :content => /Search result: 2 records found/ )
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
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :sortby => 'article_id desc',
                          :adv_search => 
                            {
                              '1_row' => {:col1 => 'title', 
                                          :col2 => 'contains', 
                                          :col3 => 'python'},
                              '2_row' => {:col1 => 'body', 
                                          :col2 => 'contains', 
                                          :col3 => 'beginners'} 
                            }
                        }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'h2', 
                 :attributes => {:class => 'title'}, 
                 :content => /Search result: 1 record found/ )
    end
  end

  context 'build advance search conditions' do
    setup do
      @klass = Object.const_get('Article')
    end

    context 'col2 not null' do
      should '' do
        hash = @controller.send(:build_advance_search_conditions, @klass,
                                { '429440_row' => { :col1 => 'body', 
                                                    :col2 => 'is_not_null'}})
        assert_equal '(articles.body IS NOT NULL)', hash[:cond]
      end
    end

    context 'col2 contains' do
      should '' do
        hash = @controller.send(:build_advance_search_conditions, @klass,
                                { '429440_row' => { :col1 => 'body', 
                                                    :col2 => 'contains', 
                                                    :col3 => 'python'}})
        assert_equal "(articles.body LIKE '%python%')", hash[:cond]
      end
    end

    context 'col2 is exactly' do
      should '' do
        hash = @controller.send(:build_advance_search_conditions, @klass,
                                { '429440_row' => { :col1 => 'body', 
                                                    :col2 => 'is_exactly', 
                                                    :col3 => 'python'}})
        assert_equal "(articles.body = 'python')", hash[:cond]
      end
    end

    context 'does not conatin' do
      should '' do
        hash = @controller.send(:build_advance_search_conditions, @klass,
                              { '429440_row' => { :col1 => 'body', 
                                                  :col2 => 'does_not_contain', 
                                                  :col3 => 'python'}})
        assert_equal "(articles.body NOT LIKE '%python%')", hash[:cond]
      end
    end

    context 'is false' do
      should '' do
        hash = @controller.send(:build_advance_search_conditions, @klass,
                              { '429440_row' => { :col1 => 'body', 
                                                  :col2 => 'is_false', 
                                                  :col3 => 'python'}})
        assert_equal "(articles.body = 'f')", hash[:cond]
      end
    end
  end #end of nested context


  context 'xhr advance_search contains +ve' do
    setup do
      Article.delete_all
      Factory(:article, :title => 'python')
      xml_http_request  :post, 
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'title', 
                                                      :col2 => 'contains', 
                                                      :col3 => 'python'} } }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag( :tag => 'h2',
                  :attributes => { :class => 'title'},
                  :content => /Search result: 1 record found/ )
    end
  end

  context 'xhr advance_search contains -ve' do
    setup do
      Article.delete_all
      Factory(:article, :title => 'ruby')
      xml_http_request :post, 
                       :advance_search, 
                       { :klass => Article.name.underscore, 
                         :adv_search => {'2_row' => { :col1 => 'title', 
                                                      :col2 => 'contains', 
                                                      :col3 => 'python'} } }
    end
    should 'contain text' do
      assert_tag( :tag => 'h2',
                  :attributes => { :class => 'title' },
                  :content => /Search result: 0 records found/ )
    end
  end

  context 'xhr advance_search is exactly +ve' do
    setup do
      Article.delete_all
      Factory(:article, :title => 'python')
      xml_http_request :post,
                       :advance_search, 
                       { :klass => Article.name.underscore, 
                         :adv_search => {'2_row' => { :col1 => 'title', 
                                                      :col2 => 'is_exactly', 
                                                      :col3 => 'python'} } }
    end
    should 'contain text' do
      assert_tag( :tag => 'h2',
                  :attributes => { :class => 'title'},
                  :content => /Search result: 1 record found/ )
    end
  end

  context 'xhr advance_search is exactly -ve' do
    setup do
      Article.delete_all
      Factory(:article, :title => 'python2')
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'title', 
                                                      :col2 => 'is_exactly', 
                                                      :col3 => 'python'} } }
    end
    should 'contain text' do
      assert_no_tag( :tag => 'h2',
                     :attributes => { :class => 'title'},
                     :content => /Search result: 1 record found/ )
    end
  end


  context 'xhr advance_search does not contain +ve' do
    setup do
      Article.delete_all
      Factory(:article, :title => 'python')
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'title', 
                                                      :col2 => 'does_not_contain', 
                                                      :col3 => 'ruby'} } }
    end
    should 'contain text' do
      assert_tag( :tag => 'h2',
                  :attributes => { :class => 'title'},
                  :content => /Search result: 1 record found/ )
    end
  end

  context 'xhr advance_search does not contain -ve' do
    setup do
      Article.delete_all
      Factory(:article, :title => 'python2')
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'title', 
                                                      :col2 => 'does_not_contain', 
                                                      :col3 => 'py'} } }
    end
    should 'contain text' do
      assert_no_tag( :tag => 'h2',
                     :attributes =>{ :class => 'title'},
                     :content => /Search result: 1 record found/ )
    end
  end

  context 'xhr advance_search is false +ve' do
    setup do
      Article.delete_all
      Factory(:article, :approved => false)
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'approved', 
                                                      :col2 => 'is_false'} } }
    end
    should 'contain text' do
      assert_tag( :tag => 'h2',
                  :attributes => {:class => 'title'},
                  :content => /Search result: 1 record found/ )
    end
  end

  context 'xhr advance_search does is false -ve' do
    setup do
      Article.delete_all
      Factory(:article, :approved => true)
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'approved', 
                                                      :col2 => 'is_false'} } }
    end
    should 'contain text' do
      assert_no_tag(:tag => 'h2',
                    :attributes => {:class => 'title'},
                    :content => /Search result: 1 record found/ )
    end
  end


  context 'xhr advance_search is true +ve' do
    setup do
      Article.delete_all
      Factory(:article, :approved => true)
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'approved', 
                                                      :col2 => 'is_true'} } }
    end
    should 'contain text' do
      assert_tag( :tag => 'h2',
                  :attributes => { :class => 'title'},
                  :content => /Search result: 1 record found/ ) 
    end
  end

  context 'xhr advance_search does is true -ve' do
    setup do
      Article.delete_all
      Factory(:article, :approved => false)
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'approved', 
                                                      :col2 => 'is_true'} } }
    end
    should 'contain text' do
      assert_no_tag(:tag => 'h2',
                    :attributes => {:class => 'title'},
                    :content => /Search result: 1 record found/ )
    end
  end


  context 'xhr advance_search is null +ve' do
    setup do
      Article.delete_all
      Factory(:article, :status => nil)
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'status', 
                                                      :col2 => 'is_null'} } }
    end
    should 'contain text' do
      assert_tag( :tag => 'h2',
                  :attributes => { :class => 'title' },
                  :content => /Search result: 1 record found/ ) 
    end
  end

  context 'xhr advance_search does is null -ve' do
    setup do
      Article.delete_all
      Factory(:article, :status => 'something')
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'status', 
                                                      :col2 => 'is_null'} } }
    end
    should 'contain text' do
      assert_no_tag(:tag => 'h2',
                    :attributes => {:class => 'title'},
                    :content => /Search result: 1 record found/ )
    end
  end


  context 'xhr advance_search is not null +ve' do
    setup do
      Article.delete_all
      Factory(:article, :status => 'something')
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'status', 
                                                      :col2 => 'is_not_null'} } }
    end
    should 'contain text' do
      assert_tag( :tag => 'h2',
                  :attributes => { :class => 'title'},
                  :content => /Search result: 1 record found/ )
    end
  end

  context 'xhr advance_search does is not null -ve' do
    setup do
      Article.delete_all
      Factory(:article, :status => nil)
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'status', 
                                                      :col2 => 'is_not_null'} } }
    end
    should 'contain text' do
      assert_no_tag( :tag => 'h2',
                     :attributes => { :class => 'title'},
                     :content => /Search result: 1 record found/ ) 
    end
  end

  context 'xhr advance_search is equal to +ve' do
    setup do
      Article.delete_all
      Factory(:article, :hits_count => 100)
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'hits_count', 
                                                      :col2 => 'is_equal_to', 
                                                      :col3 => 100.to_s} } }
    end
    should 'contain text' do
      assert_tag( :tag => 'h2',
                  :attributes => { :class => 'title' },
                  :content => /Search result: 1 record found/ ) 
    end
  end

  context 'xhr advance_search does is equal to -ve' do
    setup do
      Article.delete_all
      Factory(:article, :hits_count => 100)
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'hits_count', 
                                                      :col2 => 'is_equal_to', 
                                                      :col3 => 101.to_s} } }
    end
    should 'contain text' do
      assert_no_tag( :tag => 'h2',
                     :attributes => { :class => 'title' },
                     :content => /Search result: 1 record found/ ) 
    end
  end

  context 'xhr advance_search greater than +ve' do
    setup do
      Article.delete_all
      Factory(:article, :hits_count => 100)
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'hits_count', 
                                                      :col2 => 'greater_than', 
                                                      :col3 => 99.to_s} } }
    end
    should 'contain text' do
      assert_tag( :tag => 'h2',
                  :attributes => { :class => 'title'},
                  :content => /Search result: 1 record found/ )
    end
  end

  
  context 'xhr advance_search does greater than -ve' do
    setup do
      Article.delete_all
      Factory(:article, :hits_count => 100)
      xml_http_request  :post, 
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'hits_count', 
                                                      :col2 => 'greater_than', 
                                                      :col3 => 101.to_s} } }
    end
    should 'contain text' do
      assert_tag( :tag => 'h2',
                  :attributes => { :class => 'title'},
                  :content => /Search result: 0 records found/ )
    end
  end

  context 'xhr advance_search less than +ve' do
    setup do
      Article.delete_all
      Factory(:article, :hits_count => 100)
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'hits_count', 
                                                      :col2 => 'less_than', 
                                                      :col3 => 101.to_s} } }
    end
    should 'contain text' do
      assert_tag( :tag => 'h2',
                  :attributes => { :class => 'title' }, 
                  :content => /Search result: 1 record found/ )
    end
  end

  context 'xhr advance_search does less than -ve' do
    setup do
      Article.delete_all
      Factory(:article, :hits_count => 100)
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'hits_count', 
                                                      :col2 => 'less_than', 
                                                      :col3 => 99.to_s} } }
    end
    should 'contain text' do
      assert_no_tag( :tag => 'h2',
                     :attributes => { :class => 'h2' },
                     :content => /Search result: 1 record found/ ) 
    end
  end


  context 'xhr advance_search is_on +ve' do
    setup do
      Article.delete_all
      Factory(:article, :published_at => Time.now)
      d = Time.now.strftime('%d-%B-%Y')
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'published_at', 
                                                      :col2 => 'is_on', 
                                                      :col3 => d} } }
    end
    should 'contain text' do
      assert_tag( :tag => 'h2',
                  :attributes =>{ :class => 'title'},
                  :content => /Search result: 1 record found/ )
    end
  end

  context 'xhr advance_search is_on -ve' do
    setup do
      Article.delete_all
      Factory(:article, :published_at => Time.now)
      d = 1.year.ago.strftime('%d-%B-%Y')
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'published_at', 
                                                      :col2 => 'is_on', 
                                                      :col3 => d} } }
    end
    should 'contain text' do
      assert_no_tag( :tag => 'h2',
                     :attributes => { :class => 'title'},
                     :content => /Search result: 1 record found/ )
    end
  end

  context 'xhr advance_search is_on or after +ve' do
    setup do
      Article.delete_all
      Factory(:article, :published_at => Time.now)
      d = 1.month.ago.strftime('%d-%B-%Y')
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'published_at', 
                                                      :col2 => 'is_on_or_after_date', 
                                                      :col3 => d} } }
    end
    should 'contain text' do
      assert_tag( :tag => 'h2',
                  :attributes => { :class => 'title'},
                  :descendant => /Search result: 1 record found/ )
    end
  end

  context 'xhr advance_search is_on or after -ve' do
    setup do
      Article.delete_all
      Factory(:article, :published_at => Time.now)
      d = 1.year.from_now.strftime('%d-%B-%Y')
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'published_at', 
                                                      :col2 => 'is_on_or_after_date', 
                                                      :col3 => d} } }
    end
    should 'contain text' do
      assert_tag( :tag => 'h2', 
                  :attributes => { :class => 'title' },
                  :content => /Search result: 0 records found/ ) 
    end
  end


  context 'xhr advance_search is_on or before +ve' do
    setup do
      Article.delete_all
      Factory(:article, :published_at => Time.now)
      d = 1.month.from_now.strftime('%d-%B-%Y')
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'published_at', 
                                                      :col2 => 'is_on_or_before_date', 
                                                      :col3 => d} } }
    end
    should 'contain text' do
      assert_tag( :tag => 'h2',
                  :attributes => { :class => 'title'},
                  :content => /Search result: 1 record found/ )
    end
  end

  context 'xhr advance_search is_on or before -ve' do
    setup do
      Article.delete_all
      Factory(:article, :published_at => Time.now)
      d = 1.year.ago.strftime('%d-%B-%Y')
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'published_at', 
                                                      :col2 => 'is_on_or_before_date', 
                                                      :col3 => d} } }
    end
    should 'does contain text' do
      assert_no_tag(:tag => 'h2',
                    :attributes => {:class => 'title'},
                    :content => /Search result: 1 record found/ )
    end
  end

  context 'xhr advance_search invalid date for field is_on or before' do
    setup do
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'published_at', 
                                                      :col2 => 'is_on_or_before_date', 
                                                      :col3 => 'invalid_date'} } }
    end
    should 'contain text' do
      assert_tag(:tag => 'p',
                    :attributes => {:class => 'error'},
                    :content => /is not a valid date/ )
    end
  end

  context 'xhr advance_search invalid date for field is_on or after' do
    setup do
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'published_at', 
                                                      :col2 => 'is_on_or_after_date', 
                                                      :col3 => 'invalid_date'} } }
    end
    should 'contain text' do
      assert_tag(:tag => 'p',
                    :attributes => {:class => 'error'},
                    :content => /is not a valid date/ )
    end
  end


  context 'xhr advance_search invalid date for field is_on' do
    setup do
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'published_at', 
                                                      :col2 => 'is_on', 
                                                      :col3 => 'invalid_date'} } }
    end
    should 'contain text' do
      assert_tag(:tag => 'p',
                    :attributes => {:class => 'error'},
                    :content => /is not a valid date/ )
    end
  end


  context 'xhr advance_search invalid integer for field is_equal_to' do
    setup do
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'hits_count', 
                                                      :col2 => 'is_equal_to', 
                                                      :col3 => 'invalid_integer'} } }
    end
    should 'contain text' do
      assert_tag(:tag => 'p',
                    :attributes => {:class => 'error'},
                    :content => /is not a valid integer/ )
    end
  end

  context 'xhr advance_search invalid integer for field less_than' do
    setup do
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'hits_count', 
                                                      :col2 => 'less_than', 
                                                      :col3 => 'invalid_integer'} } }
    end
    should 'contain text' do
      assert_tag(:tag => 'p',
                    :attributes => {:class => 'error'},
                    :content => /is not a valid integer/ )
    end
  end

  context 'xhr advance_search invalid integer for field greater_than' do
    setup do
      xml_http_request  :post,
                        :advance_search, 
                        { :klass => Article.name.underscore, 
                          :adv_search => {'2_row' => {:col1 => 'hits_count', 
                                                      :col2 => 'greater_than', 
                                                      :col3 => 'invalid_integer'} } }
    end
    should 'contain text' do
      assert_tag(:tag => 'p',
                    :attributes => {:class => 'error'},
                    :content => /is not a valid integer/ )
    end
  end


end
