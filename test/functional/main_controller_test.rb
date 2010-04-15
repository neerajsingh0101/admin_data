require File.join(File.dirname(__FILE__), '..', 'test_helper')

f = File.join(File.dirname(__FILE__), '..', '..', 'app', 'views')
AdminData::MainController.prepend_view_path(f)

class AdminData::MainControllerTest < ActionController::TestCase

  def setup
    @controller = AdminData::MainController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @article = Factory(:article)
    @car = Factory(:car, :year => 2000, :brand => 'bmw')
    grant_read_only_access
    grant_update_access
  end

  should_route :get, '/admin_data', :controller => 'admin_data/main', :action => :all_models

  should_route :get, '/admin_data/klass/article/1', :controller => 'admin_data/main', :action => :show, :klass => 'article', :id => 1

  should_route :delete, '/admin_data/klass/article/1', :controller => 'admin_data/main', :action => :destroy, :klass => 'article', :id => 1

  should_route :delete, '/admin_data/klass/article/1/del', :controller => 'admin_data/main', :action => :del, :klass => 'article', :id => 1

  should_route :get, '/admin_data/klass/article/1/edit', :controller => 'admin_data/main', :action => :edit, :klass => 'article', :id => 1

  should_route :put, '/admin_data/klass/article/1', :controller => 'admin_data/main', :action => :update, :klass => 'article', :id => 1

  should_route :get, '/admin_data/klass/article/new', :controller => 'admin_data/main', :action => :new, :klass => 'article'

  should_route :post, '/admin_data/klass/article', :controller => 'admin_data/main', :action => :create, :klass => 'article'

  should_route :get, '/admin_data/klass/article/table_structure', :controller => 'admin_data/main', :action => :table_structure, :klass => 'article'

  context 'filters list testing' do
    setup do
      @before_filters = @controller.class.before_filter.select do |filter|
        filter.kind_of?(ActionController::Filters::BeforeFilter)
      end
    end
    context 'for ensure_is_allowed_to_view filter' do
      setup do
        @filter = @before_filters.detect {|filter| filter.method == :ensure_is_allowed_to_view}
      end
      should 'have filter called ensure_is_allowed_to_view' do
        assert @filter
      end
      should 'have no option for the filter' do
        assert @filter.options.blank?
      end
    end

    context 'for ensure_is_allowed_to_view_model filter' do
      setup do
        @filter = @before_filters.detect {|filter| filter.method == :ensure_is_allowed_to_view_model}
      end
      should 'have filter called ensure_is_allowed_to_view_model' do
        assert @filter
      end
      should 'have except option for all_models' do
        assert @filter.options[:except].include?('all_models')
      end
      should 'have except option for index' do
        assert @filter.options[:except].include?('index')
      end
    end

    context 'for ensure_is_allowed_to_update filter' do
      setup do
        @filter = @before_filters.detect do |filter|
          filter.method == :ensure_is_allowed_to_update
        end
      end
      should 'have filter called ensure_is_allowed_to_update' do
        assert @filter
      end
      should 'have only option for destroy' do
        assert @filter.options[:only].include?('destroy')
      end
      should 'have only option for del' do
        assert @filter.options[:only].include?('del')
      end
      should 'have only option for edit' do
        assert @filter.options[:only].include?('edit')
      end
      should 'have only option for update' do
        assert @filter.options[:only].include?('update')
      end
      should 'have only option for crate' do
        assert @filter.options[:only].include?('create')
      end
    end

    context 'for ensure_is_allowed_to_update_model filter' do
      setup do
        @filter = @before_filters.detect do |filter|
          filter.method == :ensure_is_allowed_to_update_model
        end
      end
      should 'have filter called ensure_is_allowed_to_update_model' do
        assert @filter
      end
      should 'have only option for destroy' do
        assert @filter.options[:only].include?('destroy')
      end
      should 'have only option for del' do
        assert @filter.options[:only].include?('del')
      end
      should 'have only option for edit' do
        assert @filter.options[:only].include?('edit')
      end
      should 'have only option for update' do
        assert @filter.options[:only].include?('update')
      end
      should 'have only option for create' do
        assert @filter.options[:only].include?('create')
      end
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
    should 'have table name' do
      assert_tag(:tag => 'h1', :content => "Table name : articles", :attributes => {:class => 'table_name'})
    end
  end

  context 'get all_models' do
    setup do
      get :all_models
    end
    should_respond_with :success
    should_assign_to :klasses
    should 'have xx number of models' do
      assert_equal 7, assigns(:klasses).size
    end
  end

  context 'get show for article which belongs to tech_magazine' do
    setup do
      @article.magazine = TechMagazine.create
      @article.save
      get :show, {:id => @article, :klass => @article.class.name.underscore }
    end
    should_respond_with :success
    should 'have belongs to association with magazine' do
      assert @article.magazine
    end
    should 'have association link for comments' do
      s2 = ERB::Util.html_escape('&')
      url = "/admin_data/klass/tech_magazine/#{@article.magazine.id}"
      assert_tag(:tag => 'a', :attributes => {:href => url})
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
      url = "/admin_data/quick_search/comment?base=article#{s2}children=comments#{s2}model_id=#{@article.id}"
      assert_tag(:tag => 'a', :attributes => {:href => url})
    end
  end

  context 'get show for car' do
    setup do
      @engine = Factory(:engine, :car => @car, :cylinders => 4)
      get :show, {:id => @car.id, :klass => @car.class.name.underscore }
    end
    should_respond_with :success
    should 'have one association link for engine' do
      s2 = ERB::Util.html_escape('&')
      url = "/admin_data/klass/engine/#{@engine.id}"
      assert_tag(:tag => 'a', :content => /engine/, :attributes => {:href => url})
    end
  end

  context 'get show for city' do
    setup do
      AdminDataConfig.set = { :find_conditions => { 'City' =>  lambda { |params| {:conditions => ["permanent_name =?", params[:id]] } } } }
      @city = Factory(:city, :name => 'New Delhi')
      get :show, {:id => 'new-delhi', :klass => @city.class.name.underscore }
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
      assert_tag( :tag => 'p', :attributes => {:class => 'belongs_to'}, :descendant => {:tag => 'a', :child => /article/})
    end
    should 'have link to belongs_to association' do
      s2 = ERB::Util.html_escape('&')
      url = "/admin_data/klass/article/#{@article.to_param}"
      assert_tag(:tag => 'a', :attributes => {:href => url})
    end
  end

  context 'get show for door which belongs to another class' do
    setup do
      @door = Factory(:door, :color => 'blue', :car_id => @car.id)
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
      @door = Factory(:door, :color => 'blue', :car => @car)
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
      @door = Factory(:door, :color => 'blue', :car => @car)
      delete :del, {:id => @car.id, :klass => @car.class.name.underscore }
    end
    should_respond_with :redirect
    should_change('car count', :by => -1) {Vehicle::Car.count}
    should_change('door count since del does not call callbacks', :by => 1) do
      Vehicle::Door.count
    end
  end

  context 'get edit article with attr' do
    setup do
      get :edit, {:id => @article.id, :klass => @article.class.name, :attr => 'title', :data => 'Hello World' }
    end
    should 'have input field for title' do
      assert_select('#article_title')
    end
    should 'not have input field for body' do
      assert_select('#article_body', false)
    end
  end

  context 'get edit article' do
    context 'with ignore column limit' do
      setup do
        AdminDataConfig.set = ({:ignore_column_limit => true})
        get :edit, {:id => @article.id, :klass => @article.class.name }
      end
      teardown do
        AdminDataConfig.set = ({:ignore_column_limit => false})
      end

      should 'have size 60 for title and maxlenght 255' do
        assert_tag(:tag => 'input', :attributes => {:id=> 'article_title', :size => '60', :maxlength => '255'})
      end

      should 'have size 60 for status and maxlenght 200' do
        assert_tag(:tag => 'input', :attributes => {:id=> 'article_status', :size => '60', :maxlength => '255'})
      end
    end

    context 'with enforced column limit' do

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
          assert_select "select[name='article[published_at(1i)]']"
          assert_select "select[name='article[published_at(2i)]']"
          assert_select "select[name='article[published_at(3i)]']"
          assert_select "select[name='article[published_at(4i)]']"
          assert_select "select[name='article[published_at(5i)]']"
        end
      end

      should 'have input field for title' do
        assert_select('#article_title')
      end

      should 'have size 60 for title and maxlenght 200' do
        assert_tag(:tag => 'input', :attributes => {:id=> 'article_title', :size => '60', :maxlength => '200'})
      end

      should 'have size 60 for status and maxlenght 200' do
        assert_tag(:tag => 'input', :attributes => {:id=> 'article_status', :size => '50', :maxlength => '50'})
      end

      should 'have input field for body' do
        assert_select('#article_body')
      end
    end

  end

  context 'get edit comment' do
    context 'without drop down for associations' do
      setup do
        AdminDataConfig.set = ({:drop_down_for_associations => false})
        @comment = Factory(:comment, :article => @article)
        get :edit, {:id => @comment.id, :klass => @comment.class.name.underscore }
      end
      teardown do
        AdminDataConfig.set = ({:drop_down_for_associations => true})
      end

      should_respond_with :success

      should "have input text field for belongs_to article" do
        assert_select 'form' do
          assert_tag(:tag => 'input', :attributes => {:id => 'comment_article_id', :name => 'comment[article_id]'})
        end
      end
    end
    context 'with drop down for associations' do
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
      post :update, { :klass => Article.name.underscore, :id => @article, :article => {:title => 'new title'}}
    end
    should_respond_with :redirect
    should_redirect_to('show page') { admin_data_on_k_path( :id => Article.last, :klass => Article.name.underscore) }
    should_set_the_flash_to /Record was updated/
    should_not_change('article count') { Article.count }
  end

  context 'update car successful' do
    setup do
      grant_update_access
      post :update, { :klass => Vehicle::Car.name.underscore, :id => @car.id, 'vehicle/car' => {:brand => 'honda'}}
    end
    should_respond_with :redirect
    should_redirect_to('show page') { admin_data_on_k_path(:id => Vehicle::Car.last.id, :klass => @car.class.name.underscore) }
    should_set_the_flash_to /Record was updated/
    should_not_change('car count') { Vehicle::Car.count }
  end

  context 'update failure' do
    setup do
      grant_update_access
      post :update, { :klass => 'article', :id => @article.id, :article => {:body => ''}}
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
      post :create, { :klass => Article.name.underscore, 'article' => {:title => 'hello', :body => 'hello world'}}
    end
    should_respond_with :redirect
    should_redirect_to('show page') { admin_data_on_k_path(:id => Article.last, :klass => @article.class.name.underscore) }
    should_set_the_flash_to /Record was created/
    should_change('article count', :by => 1) { Article.count }
  end

  context 'create car successful' do
    setup do
      grant_update_access
      post :create, { :klass => Vehicle::Car.name.underscore, 'vehicle/car' => {:brand => 'hello'}}
    end
    should_respond_with :redirect
    should_redirect_to('show page') { admin_data_on_k_path(:id => Vehicle::Car.last.id, :klass => @car.class.name.underscore) }
    should_set_the_flash_to /Record was created/
    should_change('vehicle count', :by => 1) { Vehicle::Car.count }
  end

  context 'create failure' do
    setup do
      grant_update_access
      post :create, { :klass => Article.name.underscore, :article => {:body => '', :title => 'hello'}}
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

  context 'fine grained access control' do
    teardown do
      AdminDataConfig.initialize_defaults
    end
    context 'allows view security check to access klass' do
      setup do
        AdminDataConfig.set = { :is_allowed_to_view_model => Proc.new { |controller| assert_equal(Article, controller.klass); true } }
        get :show, {:id => @article.id, :klass => Article.name.underscore }
      end
      should_respond_with :success
    end
    context 'allows update security check to access klass' do
      setup do
        AdminDataConfig.set = { :is_allowed_to_update => Proc.new { |controller| assert_equal(Article, controller.klass); true } }
        get :edit, {:id => @article.id, :klass => Article.name.underscore }
      end
      should_respond_with :success
    end
  end

end
