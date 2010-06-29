ActionController::Routing::Routes.draw do |map|

  map.namespace(:admin_data) do |admin_data|
    
    admin_data.with_options :controller => 'main' do |m|
      m.index                       '/',                                :action => 'all_models'
    end

    admin_data.with_options :controller => 'migration' do |m|
      m.migration_information       '/migration',                       :action => 'index'
      m.jstest                      '/jstest',                          :action => 'jstest'
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
