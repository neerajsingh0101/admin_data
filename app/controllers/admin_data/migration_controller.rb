class AdminData::MigrationController < AdminData::BaseController

  unloadable

  layout nil, :only => [:jstest]

  def index
    @page_title = 'migration information'
    m = 'select * from schema_migrations'
    @data = ActiveRecord::Base.connection.select_all(m)
    respond_to {|format| format.html}
  end

  def jstest
    @page_title = 'jstest'
    respond_to {|format| format.html}
  end


end
