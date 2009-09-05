class AdminData::MigrationController  < AdminData::BaseController 

   unloadable

   def index
      m = 'select * from schema_migrations'
      @data = ActiveRecord::Base.connection.select_all(m)
   end

end
