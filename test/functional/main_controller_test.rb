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

  should_route :get, '/admin_data',                 :controller => 'admin_data/main', 
                                                    :action => :all_models

  should_route :get, '/admin_data/article/1',       :controller => 'admin_data/main', 
                                                    :action => :show, 
                                                    :klass => 'article', 
                                                    :id => 1

  should_route :delete, '/admin_data/article/1',    :controller => 'admin_data/main', 
                                                    :action => :destroy,
                                                    :klass => 'article',
                                                    :id => 1

  should_route :delete, '/admin_data/article/1/del',  
                                                    :controller => 'admin_data/main', 
                                                    :action => :del,
                                                    :klass => 'article',
                                                    :id => 1

  should_route :get, '/admin_data/article/1/edit',  :controller => 'admin_data/main', 
                                                    :action => :edit,
                                                    :klass => 'article',
                                                    :id => 1

  should_route :put, '/admin_data/article/1',       :controller => 'admin_data/main', 
                                                    :action => :update,
                                                    :klass => 'article',
                                                    :id => 1

  should_route :get, '/admin_data/article/new',     :controller => 'admin_data/main', 
                                                    :action => :new,
                                                    :klass => 'article'

  should_route :post, '/admin_data/article',        :controller => 'admin_data/main', 
                                                    :action => :create,
                                                    :klass => 'article'

  should_route :get, '/admin_data/article/table_structure', 
                                                    :controller => 'admin_data/main', 
                                                    :action => :table_structure,
                                                    :klass => 'article'

  context 'testing filter ensure_is_allowed_to_update' do
    setup do
      @filter = @controller.class.before_filter.detect do |filter|
        filter.kind_of?(ActionController::Filters::BeforeFilter) && 
          filter.method == :ensure_is_allowed_to_update
      end
    end
    should 'have filter called ensure_is_allowed_to_update' do
      assert @filter
    end
    should 'have filter for actions' do
      assert @filter.options[:only].include?('destroy')
      assert @filter.options[:only].include?('del')
      assert @filter.options[:only].include?('edit')
      assert @filter.options[:only].include?('update')
      assert @filter.options[:only].include?('create')
    end
  end

  context 'get table_structure' do
    setup do
      get :table_structure, {:klass => Article.name.underscore}
    end
    should_respond_with :success
    should 'have text index' do
      assert_tag(:content => 'Index')
    end
  end

  context 'get all_models' do
    setup do
      get :all_models
    end
    should_respond_with :success
    should_assign_to :klasses
    should 'have 5  models' do
      assert_equal 6, assigns(:klasses).size
    end
    should 'have Home tab selected' do
       assert_select('#main-navigation ul li.first.active')
    end
  end

  context 'get show for article which has many comments' do
    setup do
      @comment1 = Factory(:comment, :article => @article)
      @comment2 = Factory(:comment, :article => @article)
      get :show, {:id => @article.id, :klass => @article.class.name.underscore }
    end
    should_respond_with :success
    should 'have association link for comments' do
       s2 = ERB::Util.html_escape('&')
       url = "/admin_data/comment/search?base=article#{s2}children=comments#{s2}id=#{@article.id}"
       assert_tag(:tag => 'a', :attributes => {:href => url})
    end
  end

  context 'get show for car' do
    setup do
      @engine = Vehicle::Engine.create(:car_id => @car.id, :cylinders => 4)
      get :show, {:id => @car.id, :klass => @car.class.name.underscore }
    end
    should_respond_with :success
  end

  context 'get show for city' do
    setup do
      AdminDataConfig.set = {
      :find_conditions => Proc.new do |params| 
         { City.name.underscore => {:conditions => { :permanent_name => params[:id]}}}
      end
      }
       
      @city = City.create(:name => 'miami')
      get :show, {:id => @city.permanent_name, :klass => @city.class.name.underscore }
    end
    should_respond_with :success
  end

  context 'get show for comment which belongs to another class' do
    setup do
      @comment = Factory(:comment, :article => @article)
      get :show, {:id => @comment.id, :klass => @comment.class.name.underscore }
    end
    should_respond_with :success
    should 'have belongs_to message' do
      assert_tag( :tag => 'p',
                  :attributes => {:class => 'belongs_to'},
                  :descendant => {:tag => 'a', :child => /article/})
    end
    should 'have link to belongs_to association' do
       s2 = ERB::Util.html_escape('&')
       url = "/admin_data/article/#{@article.to_param}"
       assert_tag(:tag => 'a', :attributes => {:href => url})
    end
  end

  context 'get show for door which belongs to another class' do
    setup do
      @door = Vehicle::Door.create(:color => 'blue', :car_id => @car.id)
      get :show, {:id => @door.id, :klass => @door.class.name.underscore }
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
      delete :destroy, {:id => @article.id, :klass => @article.class.name.underscore}
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
      delete :destroy, {:id => @car.id, :klass => @car.class.name.underscore}
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
      delete :del, {:id => @article.id, :klass => @article.class.name.underscore }
    end
    should_respond_with :redirect
    should_change('article count', :by => -1) {Article.count}
    should_change('comment count', :by => 1) {Comment.count}
  end

  context 'delete a car' do
    setup do
      grant_update_access
      @door = Vehicle::Door.create(:color => 'blue', :car_id => @car.id)
      delete :del, {:id => @car.id, :klass => @car.class.name.underscore }
    end
    should_respond_with :redirect
    should_change('car count', :by => -1) {Vehicle::Car.count}
    should_change('door count since del does not call callbacks', :by => 1) do 
      Vehicle::Door.count
    end
  end

  context 'get edit article' do
    setup do
      get :edit, {:id => @article.id, :klass => @article.class.name }
    end
    should_respond_with :success
    
    should "not have input for primary key" do
      assert_select 'form' do
        assert_select "input[name='comment[id]']", false
      end
    end

    should "have dropdowns for published_at datetime column" do
      assert_select 'form' do
        assert_select "input[type='text'][name='article[published_at(1i)]']"
        assert_select "select[name='article[published_at(4i)]']"
        assert_select "select[name='article[published_at(5i)]']"
      end
    end
    
  end

  context 'get edit comment' do
    setup do
      @comment = Factory(:comment, :article => @article)
      get :edit, {:id => @comment.id, :klass => @comment.class.name.underscore }
    end
    should_respond_with :success

    should "have dropdowns for belongs_to article" do
      assert_select 'form' do
        assert_select "select[name='comment[article_id]']"
      end
    end
  end
  

  context 'get edit car' do
    setup do
      get :edit, {:id => @car.id, :klass => @car.class.name.underscore }
    end
    should_respond_with :success
  end

  context 'get new article' do
    setup do
      get :new, {:klass => Article.name.underscore }
    end
    should_respond_with :success
  end

  context 'get new car' do
    setup do
      get :new, {:klass => Vehicle::Car.name.underscore}
    end
    should_respond_with :success
  end

  context 'update article successful' do
    setup do
      grant_update_access
      post :update, { :klass => Article.name.underscore, 
                      :id => @article, 
                      :article => {:title => 'new title'}}
    end
    should_respond_with :redirect
    should_redirect_to('show page') { admin_data_on_k_path( :id => Article.last, 
                                                            :klass => Article.name.underscore) }
    should_set_the_flash_to /Record was updated/
    should_not_change('article count') { Article.count }
  end

  context 'update car successful' do
    setup do
      grant_update_access
      post :update, { :klass => Vehicle::Car.name.underscore, 
                      :id => @car.id, 
                      'vehicle/car' => {:brand => 'honda'}}
    end
    should_respond_with :redirect
    should_redirect_to('show page') { admin_data_on_k_path(:id => Vehicle::Car.last.id, 
                                                           :klass => @car.class.name.underscore) }
    should_set_the_flash_to /Record was updated/
      should_not_change('car count') { Vehicle::Car.count }
  end

  context 'update failure' do
    setup do
      grant_update_access
      post :update, { :klass => 'article', 
                      :id => @article.id, 
                      :article => {:body => ''}}
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
      post :create, { :klass => Article.name.underscore, 
                      'article' => {:title => 'hello', :body => 'hello world'}}
    end
    should_respond_with :redirect
    should_redirect_to('show page') { admin_data_on_k_path(:id => Article.last, 
                                                           :klass => @article.class.name.underscore) }
    should_set_the_flash_to /Record was created/
      should_change('article count', :by => 1) { Article.count }
  end

  context 'create car successful' do
    setup do
      grant_update_access
      post :create, { :klass => Vehicle::Car.name.underscore, 
                      'vehicle/car' => {:brand => 'hello'}}
    end
    should_respond_with :redirect
    should_redirect_to('show page') { admin_data_on_k_path(:id => Vehicle::Car.last.id, 
                                                           :klass => @car.class.name.underscore) }
    should_set_the_flash_to /Record was created/
    should_change('vehicle count', :by => 1) { Vehicle::Car.count }
  end
  

  context 'create failure' do
    setup do
      grant_update_access
      post :create, { :klass => Article.name.underscore, 
                      :article => {:body => '', :title => 'hello'}}
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
      get :show, {:id => 999999999999994533, :klass => Article.name.underscore }
    end
    should_respond_with :not_found
    should 'contain the error message' do
      assert_tag(:tag => 'h2', :content => "Article not found: 999999999999994533")
    end
  end

  context 'filter is_allowed_to_view failure case' do
    setup do
      revoke_read_only_access
      get :show, {:id => @article.id, :klass => Article.name.underscore }
    end
    should_respond_with :unauthorized
    should 'contain the  message' do
      assert_tag(:tag => 'h2', :content => 'not authorized')
    end
  end

end
