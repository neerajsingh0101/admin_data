module AdminData
  class PublicController < ApplicationController

    def serve
      path = File.join(AdminData::LIBPATH, '..', 'app', 'assets', params[:file])

      unless File.expand_path(path) =~ /admin_data/
        render :nothing => true, :status => 404 and return
      end

      case params[:format].to_s.downcase
      when 'css'
        content_type = "text/css"
      when 'js'
        content_type = "text/javascript"
      when 'png'
        content_type = "image/png"
      when 'jpg'
        content_type = "image/jpg"
      else
        render :nothing => true, :status => 404 and return
      end

      render({:text => File.read("#{path}.#{params[:format]}"), :cache => true, :content_type => content_type})
    end

  end
end
