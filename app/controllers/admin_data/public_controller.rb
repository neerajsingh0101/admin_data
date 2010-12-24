module AdminData
  class PublicController < ApplicationController

    def serve
      path = File.join(AdminData::LIBPATH, 'public', params[:file])

      unless File.expand_path(path) =~ /admin_data/
        render :nothing => true, :status => 404 and return
      end

      case params[:file]
      when /\.css$/i
        content_type = "text/css"
      when /\.js$/i
        content_type = "text/javascript"
      when /\.png$/i
        content_type = "image/png"
      else
        render :nothing => true, :status => 404 and return
      end

      render({:text => File.read(path), :cache => true, :content_type => content_type})
    end

  end
end
