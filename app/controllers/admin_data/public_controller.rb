module AdminData
  class PublicController < BaseController

    # Serve static file from /ublic directory
    def serve

      # validate filename with a white list
      unless self.class.admin_data_assets.include? params[:file]
        render :nothing => true, :status => 404 and return
      end

      opts = {:text => File.read(File.join(AdminData.public_dir,params[:file])), :cache => true}

      case params[:file] 
      when /\.css$/i then opts[:content_type] = "text/css"
      when /\.js$/i then opts[:content_type] = "text/javascript"
      when /\.png$/i then opts[:content_type] = "image/png"
      else
        render :nothing => true, :status => 404 and return
      end

      render opts
    end

    protected

    # Cached list of all assets provided by admin_data
    # It is used to ensure security in the serve method
    def self.admin_data_assets
      @admin_data_assets ||= (
        Dir.glob(File.join(AdminData.public_dir,'**','*')).map do |path|
           # we want only relative paths
           path = path.split(AdminData.public_dir,2).last
        end
      )
    end
  end
end
