module AdminData
  class Routing
    def self.connect_with(map)
      map.with_options :controller => 'admin_data' do |m|
        m.admin_data          'admin-data' ,                      :action => 'index'
        m.admin_data          'admin_data' ,                      :action => 'index'
        m.admin_data_list     'admin_data/list' ,                 :action => 'list'
        m.admin_data_show     'admin_data/show' ,                 :action => 'show'
        m.admin_data_destroy  'admin_data/destroy',               :action => 'destroy'
        m.admin_data_delete   'admin_data/delete',                :action => 'delete'
        m.admin_data_edit     'admin_data/edit',                  :action => 'edit'
        m.admin_data_edit     'admin_data/update',                :action => 'update'
        m.admin_data_search   'admin_data/quick_search',          :action => 'quick_search'
        m.admin_data_search   'admin_data/advance_search',        :action => 'advance_search'
        m.admin_data_search   'admin_data/migration_information', :action => 'migration_information'
        m.admin_data_search   'admin_data/table_structure',       :action => 'table_structure'
        m.admin_data_search   'admin_data/new',                   :action => 'new'
        m.admin_data_search   'admin_data/create',                :action => 'create'
      end
    end
  end
end