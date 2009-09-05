require File.join(File.dirname(__FILE__) ,'..', 'test_helper')

f = File.join(File.dirname(__FILE__),'..','..','app','views')
AdminData::MainController.prepend_view_path(f)

class AdminData::MainControllerTest < ActionController::TestCase

  def setup
    @controller = AdminData::MainController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @article = Factory(:article)
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
  end

  context 'get list' do
    setup do
      get :list, {:klass => 'Article'}
    end
    should_respond_with :success
  end


  context 'get list for has_many association' do
    setup do
      @comment1 = Factory(:comment, :article => @article)
      @comment2 = Factory(:comment, :article => @article)
      get :list, {:base => 'Article', :klass => 'Comment', :model_id => @article.id, :send => 'comments'}
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

  context 'get show' do
    setup do
      get :show, {:model_id => @article.id, :klass => @article.class.name }
    end
    should_respond_with :success
  end

  context 'get show for a model which belongs to another class' do
    setup do
      @comment = Factory(:comment, :article => @article)
      get :show, {:model_id => @comment.id, :klass => @comment.class.name }
    end
    should_respond_with :success
  end




  context 'destroy' do
    setup do
      grant_update_access
      @comment = Factory(:comment, :article => @article)
      delete :destroy, {:model_id => @article.id, :klass => @article.class.name}
    end
    should_respond_with :redirect
    should_change('article count', :by => -1) {Article.count}
    # a comment is being created in setup which should be deleted because of destroy
    should_not_change('comment count') { Comment.count }
  end

  context 'delete' do
    setup do
      grant_update_access
      @comment = Factory(:comment, :article => @article)
      delete :delete, {:model_id => @article.id, :klass => @article.class.name}
    end
    should_respond_with :redirect
    should_change('article count', :by => -1) {Article.count}
    should_change('comment count', :by => 1) {Comment.count}
  end

  context 'get edit' do
    setup do
      get :edit, {:model_id => @article.id, :klass => @article.class.name }
    end
    should_respond_with :success
  end
  
  context 'get new' do
    setup do
      get :new, {:klass => 'Article' }
    end
    should_respond_with :success
  end

  context 'update successful' do
    setup do
      grant_update_access
      post :update, {:klass => 'Article', :model_id => @article.id, :article => {:title => 'new title'}}
    end
    should_respond_with :redirect
    should_redirect_to('show page') { admin_data_show_path(:model_id => Article.last.id, :klass => 'Article') }
    should_set_the_flash_to /Record was updated/
    should_not_change('article count') { Article.count }
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

  context 'create successful' do
    setup do
      grant_update_access
      post :create, {:klass => 'Article', :article => {:body => 'hello world', :title => 'hello'}}
    end
    should_respond_with :redirect
    should_redirect_to('show page') { admin_data_show_path(:model_id => Article.last.id, :klass => 'Article') }
    should_set_the_flash_to /Record was created/
    should_change('article count', :by => 1) { Article.count }
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
