require File.join(File.dirname(__FILE__) ,'..', 'test_helper')

f = File.join(File.dirname(__FILE__),'..','..','app','views')
AdminData::MainController.prepend_view_path(f)

class AdminData::MainControllerTest < ActionController::TestCase

  def setup
    @controller = AdminData::MainController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @article = Factory(:article)
    @car = Vehicle::Car.create(:year => 2000, :brand => 'bmw')
    grant_read_only_access
  end

  should_route :get, '/admin_data',                 :controller => 'admin_data/main', :action => :index

  should_route :get, '/admin_data/show',            :controller => 'admin_data/main', :action => :show

  should_route :delete, '/admin_data/destroy',      :controller => 'admin_data/main', :action => :destroy

  should_route :delete, '/admin_data/delete',       :controller => 'admin_data/main', :action => :delete

  should_route :get, '/admin_data/edit',            :controller => 'admin_data/main', :action => :edit

  should_route :post, '/admin_data/update',         :controller => 'admin_data/main', :action => :update

  should_route :get, '/admin_data/new',             :controller => 'admin_data/main', :action => :new

  should_route :post, '/admin_data/create',         :controller => 'admin_data/main', :action => :create

  should_route :get, '/admin_data/table_structure', :controller => 'admin_data/main', 
                                                    :action => :table_structure

  context 'testing filter ensure_is_allowed_to_update' do
    setup do
      @controller.class.before_filter.each do |filter|
        if filter.kind_of?(ActionController::Filters::BeforeFilter) && 
            filter.method == :ensure_is_allowed_to_update
            @filter = filter 
        end
      end
    end
    should 'have filter called ensure_is_allowed_to_update' do
      assert @filter
    end
    should 'have filter for actions' do
      assert @filter.options[:only].include?('destroy')
      assert @filter.options[:only].include?('delete')
      assert @filter.options[:only].include?('edit')
      assert @filter.options[:only].include?('update')
      assert @filter.options[:only].include?('create')
    end
  end

  context 'get table_structure' do
    setup do
      get :table_structure, {:klass => 'Article'}
    end
    should_respond_with :success
    should 'have text index' do
      assert_tag(:content => 'Index')
    end
  end

  context 'get index' do
    setup do
      get :index

    end
    should_respond_with :success
    should_assign_to :klasses
    should 'have 5  models' do
      assert_equal 5, assigns(:klasses).size
    end
    should 'have link for article' do
       assert_tag(:tag => 'a', :attributes => {:href => '/admin_data/list?klass=article'})
    end
    should 'have link for engine' do
       s = CGI.escape('vehicle/engine')
       assert_tag(:tag => 'a', :attributes => {:href => "/admin_data/list?klass=#{s}" } )
    end
  end

  context 'get list for article' do
    setup do
      get :list, {:klass => @article.class.name.underscore}
    end
    should_respond_with :success
  end

  context 'get list for car' do
    setup do
      get :list, {:klass => @car.class.name.underscore}
    end
    should_respond_with :success
    should 'contain proper link at header' do
       s = CGI.escape('vehicle/car')
       assert_tag(:tag => 'div', :attributes => {:class => 'breadcrum'},
                  :descendant => {:tag => 'a', :attributes => { :href => "/admin_data/list?klass=#{s}" }})
    end
    should 'contain proper link at table listing' do
       s1 = CGI.escape("vehicle/car")
       s2 = ERB::Util.html_escape('&')
       url = "/admin_data/show?klass=#{s1}#{s2}model_id=#{@car.id}"
       assert_tag(:tag => 'td',
                  :descendant => {:tag => 'a', :attributes => { :href => url }})
    end
  end

  context 'get list article has_many association' do
    setup do
      @comment1 = Factory(:comment, :article => @article)
      @comment2 = Factory(:comment, :article => @article)
      get :list, {:base => 'Article', :klass => 'Comment', :model_id => @article.id, :children => 'comments'}
    end
    should_respond_with :success
    should_assign_to :records
    should 'have 2 records' do
      assert_equal 2, assigns(:records).size
    end
    should 'contain text' do
      assert_tag(:tag => 'div', 
                 :attributes => {:class => 'page_info'}, 
                 :descendant => {:tag => 'b', :child => /all 2/})
    end
  end

  context 'get list car has_many association' do
    setup do
      @door1 = Vehicle::Door.create(:color => 'black', :car_id => @car.id) 
      @door2 = Vehicle::Door.create(:color => 'green', :car_id => @car.id) 
      get :list, {:base => @car.class.name.underscore, 
                  :klass => @door1.class.name.underscore, 
                  :model_id => @car.id, 
                  :children => 'doors'}
    end
    should_respond_with :success
    should_assign_to :records
    should 'have 2 records' do
      assert_equal 2, assigns(:records).size
    end
    should 'contain text' do
      assert_tag(:tag => 'div', 
                 :attributes => {:class => 'page_info'}, 
                 :descendant => {:tag => 'b', :child => /all 2/})
    end
  end

  context 'get show for article which has many comments' do
    setup do
      @comment1 = Factory(:comment, :article => @article)
      @comment2 = Factory(:comment, :article => @article)
      get :show, {:model_id => @article.id, :klass => @article.class.name }
    end
    should_respond_with :success
    should 'have association link for comments' do
       s2 = ERB::Util.html_escape('&')
       url = "/admin_data/list?base=article#{s2}children=comments#{s2}klass=comment#{s2}model_id=#{@article.id}"
       assert_tag(:tag => 'a', :attributes => {:href => url})
    end
  end

  context 'get show for car' do
    setup do
      @engine = Vehicle::Engine.create(:car_id => @car.id, :cylinders => 4)
      get :show, {:model_id => @car.id, :klass => @car.class.name.underscore }
    end
    should_respond_with :success
  end


  context 'get show for comment which belongs to another class' do
    setup do
      @comment = Factory(:comment, :article => @article)
      get :show, {:model_id => @comment.id, :klass => @comment.class.name.underscore }
    end
    should_respond_with :success
    should 'have belongs_to message' do
      assert_tag( :tag => 'p',
                  :attributes => {:class => 'belongs_to'},
                  :descendant => {:tag => 'a', :child => /article/})
    end
  end

  context 'get show for door which belongs to another class' do
    setup do
      @door = Vehicle::Door.create(:color => 'blue', :car_id => @car.id)
      get :show, {:model_id => @door.id, :klass => @door.class.name.underscore }
    end
    should_respond_with :success
    should 'have belongs_to message' do
      assert_tag( :tag => 'p',
                 :attributes => {:class => 'belongs_to'},
                 :descendant => {:tag => 'a', :child => /car/})
    end
  end

  context 'destroy an article' do
    setup do
      grant_update_access
      @comment = Factory(:comment, :article => @article)
      delete :destroy, {:model_id => @article.id, :klass => @article.class.name.underscore}
    end
    should_respond_with :redirect
    should_change('article count', :by => -1) {Article.count}
    # a comment is being created in setup which should be deleted because of destroy
    should_not_change('comment count') { Comment.count }
  end

  context 'destroy a car' do
    setup do
      grant_update_access
      @door = Vehicle::Door.create(:color => 'blue', :car_id => @car.id)
      delete :destroy, {:model_id => @car.id, :klass => @car.class.name.underscore}
    end
    should_respond_with :redirect
    should_change('car count', :by => -1) {Vehicle::Car.count}
    # a comment is being created in setup which should be deleted because of destroy
    should_not_change('door count') { Vehicle::Door.count }
  end

  context 'delete an article' do
    setup do
      grant_update_access
      @comment = Factory(:comment, :article => @article)
      delete :delete, {:model_id => @article.id, :klass => @article.class.name.underscore }
    end
    should_respond_with :redirect
    should_change('article count', :by => -1) {Article.count}
    should_change('comment count', :by => 1) {Comment.count}
  end

  context 'delete a car' do
    setup do
      grant_update_access
      @door = Vehicle::Door.create(:color => 'blue', :car_id => @car.id)
      delete :delete, {:model_id => @car.id, :klass => @car.class.name.underscore }
    end
    should_respond_with :redirect
    should_change('car count', :by => -1) {Vehicle::Car.count}
    should_change('door count', :by => 1) {Vehicle::Door.count}
  end







  context 'get edit article' do
    setup do
      get :edit, {:model_id => @article.id, :klass => @article.class.name }
    end
    should_respond_with :success
  end

  context 'get edit car' do
    setup do
      get :edit, {:model_id => @car.id, :klass => @car.class.name.underscore }
    end
    should_respond_with :success
  end
  
  context 'get new article' do
    setup do
      get :new, {:klass => 'Article' }
    end
    should_respond_with :success
  end

  context 'get new car' do
    setup do
      get :new, {:klass => 'vehicle/car' }
    end
    should_respond_with :success
  end

  context 'update article successful' do
    setup do
      grant_update_access
      post :update, {:klass => 'Article', :model_id => @article.id, :article => {:title => 'new title'}}
    end
    should_respond_with :redirect
    should_redirect_to('show page') { admin_data_show_path(:model_id => Article.last.id, :klass => 'article') }
    should_set_the_flash_to /Record was updated/
    should_not_change('article count') { Article.count }
  end

  context 'update car successful' do
    setup do
      grant_update_access
      post :update, {:klass => 'vehicle/car', :model_id => @car.id, 'vehicle/car' => {:brand => 'honda'}}
    end
    should_respond_with :redirect
    should_redirect_to('show page') { admin_data_show_path(:model_id => Vehicle::Car.last.id, 
                                                           :klass => @car.class.name.underscore) }
    should_set_the_flash_to /Record was updated/
      should_not_change('car count') { Vehicle::Car.count }
  end

  context 'update failure' do
    setup do
      grant_update_access
      post :update, {:klass => 'Article', :model_id => @article.id, :article => {:body => ''}}
    end
    should_respond_with :success
    should_not_set_the_flash
    should_not_change('article count') { Article.count }
    should 'contain the error message' do
      assert_tag(:content => "Body can't be blank")
    end
  end

  context 'create article successful' do
    setup do
      grant_update_access
      post :create, {:klass => 'article', 'article' => {:title => 'hello', :body => 'hello world'}}
    end
    should_respond_with :redirect
    should_redirect_to('show page') { admin_data_show_path(:model_id => Article.last.id, 
                                                           :klass => @article.class.name.underscore) }
    should_set_the_flash_to /Record was created/
      should_change('article count', :by => 1) { Article.count }
  end

  context 'create car successful' do
    setup do
      grant_update_access
      post :create, {:klass => 'vehicle/car', 'vehicle/car' => {:brand => 'hello'}}
    end
    should_respond_with :redirect
    should_redirect_to('show page') { admin_data_show_path(:model_id => Vehicle::Car.last.id, 
                                                           :klass => @car.class.name.underscore) }
    should_set_the_flash_to /Record was created/
    should_change('vehicle count', :by => 1) { Vehicle::Car.count }
  end
  

  context 'create failure' do
    setup do
      grant_update_access
      post :create, {:klass => 'Article', :article => {:body => '', :title => 'hello'}}
    end
    should_respond_with :success
    should_not_set_the_flash
    should_not_change('article count') { Article.count }
    should 'contain the error message' do
      assert_tag(:content => "Body can't be blank")
    end
  end

  context 'filter get_model_and_verify_if failure case' do
    setup do
      get :show, {:model_id => 999999999999994533, :klass => 'Article' }
    end
    should_respond_with :not_found
    should 'contain the error message' do
      assert_tag(:tag => 'h2', :content => "Article not found: 999999999999994533")
    end
  end

  context 'filter is_allowed_to_view failure case' do
    setup do
      revoke_read_only_access
      get :show, {:model_id => @article.id, :klass => 'Article' }
    end
    should_respond_with :unauthorized
    should 'contain the  message' do
      assert_tag(:tag => 'h2', :content => 'not authorized')
    end
  end

end



