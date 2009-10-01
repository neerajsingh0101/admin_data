ActionController::Routing::Routes.draw do |map|

  map.namespace(:admin_data) do |admin_data|
    
    admin_data.with_options :controller => 'main' do |m|
      m.index                       '/',                              :action => 'all_models'
    end

    admin_data.with_options :controller => 'diagnostic' do |m|
      m.diagnostic                  '/diagnostic',                    :action => 'index'
      m.diagnostic_missing_index    '/missing_index',                 :action => 'missing_index'
    end

    admin_data.with_options :controller => 'migration' do |m|
      m.migration_information       '/migration',                     :action => 'index'
    end

    admin_data.with_options :controller => 'search' do |m|
      m.search                      '/:klass/search',                 :action => 'search'
      m.advance_search              '/:klass/advance_search',         :action => 'advance_search'
    end

    admin_data.resources  :on_k,
                          :as => ':klass',
                          :path_prefix => 'admin_data',
                          :controller => 'main',
                          :member => {:del => :delete},
                          :collection => {:table_structure => :get}

  end

  #map.with_options :controller => 'admin_data/main' do |m|

    #m.admin_data_show               '/admin_data/show' ,              :action => 'show'

    #m.admin_data_destroy            '/admin_data/destroy',            :action => 'destroy', 
                                                                      #:conditions => {:method => :delete}

    #m.admin_data_delete             '/admin_data/delete',             :action => 'delete', 
                                                                      #:conditions => {:method => :delete}

    #m.admin_data_edit               '/admin_data/edit',               :action => 'edit'
    
    #m.admin_data_update             '/admin_data/update',             :action => 'update', 
                                                                      #:conditions => {:method => :post}

    #m.admin_data_table_structure    '/admin_data/table_structure',    :action => 'table_structure'

    #m.admin_data_new                '/admin_data/new',                :action => 'new'

    #m.admin_data_create             '/admin_data/create',             :action => 'create', 
                                                                      #:conditions => {:method => :post}
  #end

end
