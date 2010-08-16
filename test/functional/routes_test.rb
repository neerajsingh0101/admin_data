pwd = File.dirname(__FILE__)

require File.join(pwd, '..', 'test_helper')

class AdminData::MainControllerTest < ActionController::TestCase

  should route(:get, '/admin_data').to(:controller => 'admin_data/main', 
                                       :action => :all_models)

  should route(:get, '/admin_data').to(:controller => 'admin_data/main', 
                                       :action => :all_models)

  should route(:get, '/admin_data/klass/article/1').to(:controller => 'admin_data/main', 
                                                       :action => :show, 
                                                       :klass => 'article', 
                                                       :id => 1)

  should route(:delete, '/admin_data/klass/article/1').to(:controller => 'admin_data/main', 
                                                          :action => :destroy, 
                                                          :klass => 'article', 
                                                          :id => 1)

  should route(:delete, '/admin_data/klass/article/1/del').to(:controller => 'admin_data/main', 
                                                              :action => :del, 
                                                              :klass => 'article', 
                                                              :id => 1)

  should route(:get, '/admin_data/klass/article/1/edit').to(:controller => 'admin_data/main', 
                                                            :action => :edit, 
                                                            :klass => 'article', 
                                                            :id => 1)

  should route(:put, '/admin_data/klass/article/1').to(:controller => 'admin_data/main', 
                                                       :action => :update, 
                                                       :klass => 'article', 
                                                       :id => 1)

  should route(:get, '/admin_data/klass/article/new').to(:controller => 'admin_data/main', 
                                                         :action => :new, 
                                                         :klass => 'article')

  should route(:post, '/admin_data/klass/article').to(:controller => 'admin_data/main', 
                                                      :action => :create, 
                                                      :klass => 'article')

  should route(:get, '/admin_data/klass/article/table_structure').to(:controller => 'admin_data/main', 
                                                                     :action => :table_structure, 
                                                                     :klass => 'article')

end
