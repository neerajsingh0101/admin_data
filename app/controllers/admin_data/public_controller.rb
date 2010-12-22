module AdminData
  class PublicController < ApplicationController

    def serve
      path = File.join(AdminData::LIBPATH, 'public', params[:file])

      unless File.expand_path(path) =~ /admin_data/
        render :nothing => true, :status => 404 and return
      end

      opts = {:text => File.read(path), :cache => true}

      case params[:file]
      when /\.css$/i
        opts[:content_type] = "text/css"
      when /\.js$/i
        opts[:content_type] = "text/javascript"
      when /\.png$/i
        opts[:content_type] = "image/png"
      else
        render :nothing => true, :status => 404 and return
      end

      render opts
    end

  end
end
