
ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'admin_data/main' do |m|
    m.admin_data                    '/admin_data' ,                 :action => 'index'
    m.admin_data_list               '/admin_data/list' ,            :action => 'list'
    m.admin_data_show               '/admin_data/show' ,            :action => 'show'

    m.admin_data_destroy            '/admin_data/destroy',          
                                    :action => 'destroy',
                                    :conditions => {:method => :delete}

    m.admin_data_delete             '/admin_data/delete',           
                                    :action => 'delete',
                                    :conditions => {:method => :delete}


    m.admin_data_edit               '/admin_data/edit',             :action => 'edit'
    
    m.admin_data_update             '/admin_data/update',           
                                    :action => 'update',
                                    :conditions => {:method => :post}

    m.admin_data_table_structure    '/admin_data/table_structure',  :action => 'table_structure'
    m.admin_data_new                '/admin_data/new',              :action => 'new'

    m.admin_data_create             '/admin_data/create',           
                                    :action => 'create',
                                    :conditions => {:method => :post}
  end

  map.with_options :controller => 'admin_data/search' do |m|
    m.admin_data_search         '/admin_data/quick_search',         :action => 'quick_search'
    m.admin_data_advance_search '/admin_data/advance_search',       :action => 'advance_search'
  end
  
  map.with_options :controller => 'admin_data/diagnostic' do |m|
    m.admin_data_diagnostic         '/admin_data/diagnostic',         :action => 'index'
    m.admin_data_diagnostic_missing_index '/admin_data/missing_index',:action => 'missing_index'
  end
  
  map.with_options :controller => 'admin_data/migration' do |m|
    m.admin_data_migration_information  '/admin_data/migration',         :action => 'index'
  end

end
