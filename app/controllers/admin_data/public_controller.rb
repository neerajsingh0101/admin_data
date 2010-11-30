
class AdminData::PublicController < AdminData::BaseController

  def serve

    # validate filename with a white list
    unless self.class.admin_data_assets.include? params[:file]
      render :nothing => true, :status => 404 and return
    end

    #TODO: DRY plugin_dir
    public_dir = File.expand_path(File.join(AdminData::LIBPATH,'..','public')) + File::SEPARATOR

    opts = {:text => File.read(File.join(public_dir,params[:file])), :cache => true}

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
      public_dir = File.expand_path(File.join(AdminData::LIBPATH,'..','public')) + File::SEPARATOR
      Dir.glob(File.join(public_dir,'**','*')).map do |path|
         # we want only relative paths
         path = path.split(public_dir,2).last
      end
    )
  end


end
