require File.join(File.dirname(__FILE__) ,'..', 'test_helper')

f = File.join(File.dirname(__FILE__),'..','..','app','views')
AdminData::MainController.prepend_view_path(f)
AdminData::SearchController.prepend_view_path(f)

class AdminData::SearchControllerTest < ActionController::TestCase

  def setup
    @controller = AdminData::SearchController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    grant_read_only_access
  end

  should_route :get, '/admin_data/quick_search',  :controller => 'admin_data/search',
                                                  :action => :quick_search

  should_route :get, '/admin_data/advance_search',:controller => 'admin_data/search',
                                                  :action => :advance_search

  context 'get quick_search with no klass param' do
    setup do
      get :quick_search
    end
    should_respond_with :redirect
    should_redirect_to('admin_data root') {admin_data_url}
  end

  context 'get quick_search with no search param' do
    setup do
      get :quick_search, {:klass => 'Article'}
    end
    should_respond_with :success
    should_assign_to :records
  end

  context 'get quick_search with search term' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure')
      get :quick_search, {:klass => 'Article', :query => 'python'}
    end
    should_respond_with :success
    should_assign_to :records
    should 'have only one record' do
      assert_equal 2, assigns(:records).size
      assert_equal @python_book.id, assigns(:records).first.id
      assert_equal @python_beginner_book.id, assigns(:records).last.id
    end
  end

  context 'get quick_search with search term with revert id order' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure')
      get :quick_search, {:klass => 'Article', :query => 'python', :sortby => 'article_id desc'}
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
      get :advance_search
    end
    should_respond_with :redirect
    should_redirect_to('admin_data root') {admin_data_url}
  end

  context 'get advance_search with klass param' do
    setup do
      get :advance_search, {:klass => 'Article'}
    end
    should_respond_with :success
    should_assign_to :records
  end

  context 'xhr advance_search with 2 results' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure')
      xml_http_request :post,:advance_search, {:klass => 'Article', 
                            :search_type => 'advance',
                            :sortby => 'article_id desc',
                            :adv_search => {'1_row' => {'col1' => 'title', :col2 => 'contains', :col3 => 'python'} }
                            }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'div', 
                 :attributes => {:class => 'page_info'}, 
                 :descendant => {:tag => 'b', :child => /all 2/})
    end
  end

  context 'xhr advance_search with 1 result' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure')
      xml_http_request :post,:advance_search, {:klass => 'Article', 
                            :search_type => 'advance',
                            :sortby => 'article_id desc',
                            :adv_search => {'1_row' => {'col1' => 'title', :col2 => 'contains', :col3 => 'clojure'} }
                            }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'div', 
                 :attributes => {:class => 'page_info'}, 
                 :descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search with empty query term' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure')
      xml_http_request :post,:advance_search, {:klass => 'Article', 
                            :search_type => 'advance',
                            :sortby => 'article_id desc',
                            :adv_search => {'1_row' => {'col1' => 'title', :col2 => 'contains', :col3 => ''} }
                            }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'div', 
                 :attributes => {:class => 'page_info'}, 
                 :descendant => {:tag => 'b', :child => /all 4/})
    end
  end

  context 'xhr advance_search with empty col2' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners')
      xml_http_request :post,:advance_search, {:klass => 'Article', 
                            :search_type => 'advance',
                            :sortby => 'article_id desc',
                            :adv_search => {'1_row' => {'col1' => 'title', :col2 => nil, :col3 => nil} }
                            }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'div', 
                 :attributes => {:class => 'page_info'}, 
                 :descendant => {:tag => 'b', :child => /all 2/})
    end
  end

  context 'xhr advance_search with two search terms' do
    setup do
      Article.delete_all
      @python_book = Factory(:article, :title => 'python')
      @python_beginner_book = Factory(:article, :title => 'python for beginners', :body => 'for beginners')
      @java_book = Factory(:article, :title => 'java')
      @clojure_book = Factory(:article, :title => 'clojure', :body => 'not for beginners')
      xml_http_request :post,:advance_search, {:klass => 'Article', 
                            :search_type => 'advance',
                            :sortby => 'article_id desc',
                            :adv_search => {
                                '1_row' => {'col1' => 'title', :col2 => 'contains', :col3 => 'python'},
                                '2_row' => {'col1' => 'body', :col2 => 'contains', :col3 => 'beginners'} 
                                }
                            }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'div', 
                 :attributes => {:class => 'page_info'}, 
                 :descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'build advance search conditions' do
    setup do
      @klass = Object.const_get('Article')
    end

    context 'col2 not null' do
      should '' do
        cond = @controller.send(:build_advance_search_conditions, @klass,
                                { '429440_row' => {:col1 => 'body', :col2 => 'is_not_null'}})
        assert_equal '(articles.body IS NOT NULL)', cond
      end
    end

    context 'col2 contains' do
      should '' do
        cond = @controller.send(:build_advance_search_conditions, @klass,
                                { '429440_row' => {:col1 => 'body', :col2 => 'contains', :col3 => 'python'}})
        assert_equal "(articles.body LIKE '%python%')", cond
      end
    end

    context 'col2 is exactly' do
      should '' do
        cond = @controller.send(:build_advance_search_conditions, @klass,
                                { '429440_row' => {:col1 => 'body', :col2 => 'is_exactly', :col3 => 'python'}})
        assert_equal "(articles.body = 'python')", cond
      end
    end

    context 'does not conatin' do
      should '' do
        cond = @controller.send(:build_advance_search_conditions, @klass,
                              { '429440_row' => {:col1 => 'body', :col2 => 'does_not_contain', :col3 => 'python'}})
        assert_equal "(articles.body NOT LIKE '%python%')", cond
      end
    end

    context 'is false' do
      should '' do
        cond = @controller.send(:build_advance_search_conditions, @klass,
                              { '429440_row' => {:col1 => 'body', :col2 => 'is_false', :col3 => 'python'}})
        assert_equal "(articles.body = 'f')", cond
      end
    end
  end #end of nested context


  context 'xhr advance_search contains +ve' do
    setup do
      Article.delete_all
      Factory(:article, :title => 'python')
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'title', :col2 => 'contains', :col3 => 'python'} } }
    end
    should_respond_with :success
    should 'contain text' do
      assert_tag(:tag => 'div',:attributes => {:class => 'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end


  context 'xhr advance_search contains -ve' do
    setup do
      Article.delete_all
      Factory(:article, :title => 'ruby')
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'title', :col2 => 'contains', :col3 => 'python'} } }
    end
    should 'contain text' do
      assert_no_tag(:tag => 'div',:attributes =>{:class=>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end


  context 'xhr advance_search is exactly +ve' do
    setup do
      Article.delete_all
      Factory(:article, :title => 'python')
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'title', :col2 => 'is_exactly', :col3 => 'python'} } }
    end
    should 'contain text' do
      assert_tag(:tag=>'div',:attributes=>{:class=>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search is exactly -ve' do
    setup do
      Article.delete_all
      Factory(:article, :title => 'python2')
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'title', :col2 => 'is_exactly', :col3 => 'python'} } }
    end
    should 'contain text' do
      assert_no_tag(:tag=>'div',:attributes=>{:class =>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end


  context 'xhr advance_search does not contain +ve' do
    setup do
      Article.delete_all
      Factory(:article, :title => 'python')
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'title', :col2 => 'does_not_contain', :col3 => 'ruby'} } }
    end
    should 'contain text' do
      assert_tag(:tag=>'div',:attributes=>{:class=>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search does not contain -ve' do
    setup do
      Article.delete_all
      Factory(:article, :title => 'python2')
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'title', :col2 => 'does_not_contain', :col3 => 'py'} } }
    end
    should 'contain text' do
      assert_no_tag(:tag=>'div',:attributes=>{:class =>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search is false +ve' do
    setup do
      Article.delete_all
      Factory(:article, :approved => false)
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'approved', :col2 => 'is_false'} } }
    end
    should 'contain text' do
      assert_tag(:tag=>'div',:attributes=>{:class=>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search does is false -ve' do
    setup do
      Article.delete_all
      Factory(:article, :approved => true)
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'approved', :col2 => 'is_false'} } }
    end
    should 'contain text' do
      assert_no_tag(:tag=>'div',:attributes=>{:class =>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end


  context 'xhr advance_search is true +ve' do
    setup do
      Article.delete_all
      Factory(:article, :approved => true)
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'approved', :col2 => 'is_true'} } }
    end
    should 'contain text' do
      assert_tag(:tag=>'div',:attributes=>{:class=>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search does is true -ve' do
    setup do
      Article.delete_all
      Factory(:article, :approved => false)
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'approved', :col2 => 'is_true'} } }
    end
    should 'contain text' do
      assert_no_tag(:tag=>'div',:attributes=>{:class =>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end


  context 'xhr advance_search is null +ve' do
    setup do
      Article.delete_all
      Factory(:article, :status => nil)
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'status', :col2 => 'is_null'} } }
    end
    should 'contain text' do
      assert_tag(:tag=>'div',:attributes=>{:class=>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search does is null -ve' do
    setup do
      Article.delete_all
      Factory(:article, :status => 'something')
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'status', :col2 => 'is_null'} } }
    end
    should 'contain text' do
      assert_no_tag(:tag=>'div',:attributes=>{:class =>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end


  context 'xhr advance_search is not null +ve' do
    setup do
      Article.delete_all
      Factory(:article, :status => 'something')
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'status', :col2 => 'is_not_null'} } }
    end
    should 'contain text' do
      assert_tag(:tag=>'div',:attributes=>{:class=>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search does is not null -ve' do
    setup do
      Article.delete_all
      Factory(:article, :status => nil)
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'status', :col2 => 'is_not_null'} } }
    end
    should 'contain text' do
      assert_no_tag(:tag=>'div',:attributes=>{:class =>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search is equal to +ve' do
    setup do
      Article.delete_all
      Factory(:article, :hits_count => 100)
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'hits_count', :col2 => 'is_equal_to', :col3 => 100.to_s} } }
    end
    should 'contain text' do
      assert_tag(:tag=>'div',:attributes=>{:class=>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search does is equal to -ve' do
    setup do
      Article.delete_all
      Factory(:article, :hits_count => 100)
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'hits_count', :col2 => 'is_equal_to', :col3 => 101.to_s} } }
    end
    should 'contain text' do
      assert_no_tag(:tag=>'div',:attributes=>{:class =>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search greater than +ve' do
    setup do
      Article.delete_all
      Factory(:article, :hits_count => 100)
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'hits_count', :col2 => 'greater_than', :col3 => 99.to_s} } }
    end
    should 'contain text' do
      assert_tag(:tag=>'div',:attributes=>{:class=>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search does greater than -ve' do
    setup do
      Article.delete_all
      Factory(:article, :hits_count => 100)
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'hits_count', :col2 => 'greater_than', :col3 => 101.to_s} } }
    end
    should 'contain text' do
      assert_no_tag(:tag=>'div',:attributes=>{:class =>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search less than +ve' do
    setup do
      Article.delete_all
      Factory(:article, :hits_count => 100)
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'hits_count', :col2 => 'less_than', :col3 => 101.to_s} } }
    end
    should 'contain text' do
      assert_tag(:tag=>'div',:attributes=>{:class=>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search does less than -ve' do
    setup do
      Article.delete_all
      Factory(:article, :hits_count => 100)
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'hits_count', :col2 => 'less_than', :col3 => 99.to_s} } }
    end
    should 'contain text' do
      assert_no_tag(:tag=>'div',:attributes=>{:class =>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end


  context 'xhr advance_search is_on +ve' do
    setup do
      Article.delete_all
      Factory(:article, :published_at => Time.now)
      d = Time.now.strftime('%d-%B-%Y')
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'published_at', :col2 => 'is_on', :col3 => d} } }
    end
    should 'contain text' do
      assert_tag(:tag=>'div',:attributes=>{:class=>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search is_on -ve' do
    setup do
      Article.delete_all
      Factory(:article, :published_at => Time.now)
      d = 1.year.ago.strftime('%d-%B-%Y')
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {:col1 => 'published_at', :col2 => 'is_on', :col3 => d} } }
    end
    should 'contain text' do
      assert_no_tag(:tag=>'div',:attributes=>{:class =>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search is_on or after +ve' do
    setup do
      Article.delete_all
      Factory(:article, :published_at => Time.now)
      d = 1.month.ago.strftime('%d-%B-%Y')
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'published_at', :col2 => 'is_on_or_after_date', :col3 => d} } }
    end
    should 'contain text' do
      assert_tag(:tag=>'div',:attributes=>{:class=>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search is_on or after -ve' do
    setup do
      Article.delete_all
      Factory(:article, :published_at => Time.now)
      d = 1.year.from_now.strftime('%d-%B-%Y')
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {:col1 => 'published_at', :col2 => 'is_on_or_after_date', :col3 => d} } }
    end
    should 'contain text' do
      assert_no_tag(:tag=>'div',:attributes=>{:class =>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end


  context 'xhr advance_search is_on or before +ve' do
    setup do
      Article.delete_all
      Factory(:article, :published_at => Time.now)
      d = 1.month.from_now.strftime('%d-%B-%Y')
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {'col1' => 'published_at', :col2 => 'is_on_or_before_date', :col3 => d} } }
    end
    should 'contain text' do
      assert_tag(:tag=>'div',:attributes=>{:class=>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

  context 'xhr advance_search is_on or before -ve' do
    setup do
      Article.delete_all
      Factory(:article, :published_at => Time.now)
      d = 1.year.ago.strftime('%d-%B-%Y')
      xml_http_request :post,:advance_search, {:klass => 'Article', :search_type => 'advance',
          :adv_search => {'2_row' => {:col1 => 'published_at', :col2 => 'is_on_or_before_date', :col3 => d} } }
    end
    should 'contain text' do
      assert_no_tag(:tag=>'div',:attributes=>{:class =>'page_info'},:descendant => {:tag => 'b', :child => /1/})
    end
  end

end
