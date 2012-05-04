module AdminData
  class HomeController < ApplicationController

    layout 'admin_data'

    def index
      respond_to do |format|
        format.html
      end
    end

  end
end
