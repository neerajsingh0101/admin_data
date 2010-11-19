
class AdminData::PublicController < AdminData::BaseController

  def serve
    f = File.join(AdminData::Config.setting[:plugin_dir], 'lib', params[:file])
    if not File.exists? f then
      return render :nothing => true, :status => 404
    end
    opts = {:text => File.new(f).read, :cache => true}
    if f =~ /css$/ then
      opts[:content_type] = "text/css"
    elsif f =~ /js$/ then
      opts[:content_type] = "text/javascript"
    end
    render opts
  end

end