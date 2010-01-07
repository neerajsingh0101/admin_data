ActionController::Routing::Routes.draw do |map|

  map.namespace(:admin_data) do |admin_data|
    
    admin_data.with_options :controller => 'main' do |m|
      m.index                       '/',                                :action => 'all_models'
    end

    admin_data.with_options :controller => 'diagnostic' do |m|
      m.diagnostic                  '/diagnostic',                      :action => 'index'
      m.diagnostic_missing_index    '/diagnostic/missing_index',        :action => 'missing_index'
    end

    admin_data.with_options :controller => 'validate_model' do |m|
      m.validate_model_index        '/diagnostic/validate',             :action => 'index'
      m.validate_model_validate     '/diagnostic/validate_model',       :action => 'validate'
    end

    admin_data.with_options :controller => 'migration' do |m|
      m.migration_information       '/migration',                       :action => 'index'
    end

    admin_data.with_options :controller => 'feed' do |m|
      m.feed                        '/feed/:klasss',                    :action => 'index', 
                                                                        :format => :rss
    end

    admin_data.with_options :controller => 'search' do |m|
      m.search                      '/quick_search/:klass',             :action => 'quick_search'
      m.advance_search              '/advance_search/:klass',           :action => 'advance_search'
    end

    admin_data.resources  :on_k,
                          :as => ':klass',
                          :path_prefix => 'admin_data/klass',
                          :controller => 'main',
                          :member => {:del => :delete},
                          :collection => {:table_structure => :get}

  end

end
