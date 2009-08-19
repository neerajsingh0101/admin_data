class AdminData::MigrationController  < ApplicationController

   layout 'admin_data'

   include AdminData::Chelper

   unloadable

   before_filter :ensure_is_allowed_to_view
   before_filter :build_klasses

   def index
      @data = ActiveRecord::Base.connection.select_all('select * from schema_migrations');
   end

end
