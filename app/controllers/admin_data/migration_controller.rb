module AdminData
  class MigrationController < ApplicationController

    before_filter :ensure_is_allowed_to_view

    def index
      @page_title = 'migration information'
      @data = ActiveRecord::Base.connection.select_all('select * from schema_migrations')
      respond_to {|format| format.html}
    end

    def jstest
      @page_title = 'jstest'
      respond_to {|format| format.html { render :layout => false}}
    end

  end
end
