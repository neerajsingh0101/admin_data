class AdminData::MigrationController < AdminData::BaseController 

  unloadable

  def index
    @page_title = 'migration information'
    m = 'select * from schema_migrations'
    @data = ActiveRecord::Base.connection.select_all(m)
    respond_to {|format| format.html}
  end

end
