
class AdminData::PublicController < AdminData::BaseController

  def serve
    f = File.join(AdminData::Config.setting[:plugin_dir], 'lib', params[:file])

    # this is needed so that a user is not able to get data by performing url like
    # http://localhost:3000/admin_data/public/..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2Fetc%2Fpasswd
    # Above url will try to get /etc/passwd
    # 
    # Second layer of security is below which ensures that request file must end with
    # js or css
    unless Regexp.new(Rails.root.to_s).match(File.expand_path(f))
      render :nothing => true, :status => 404 and return
    end

    unless File.exists?(f)
      render :nothing => true, :status => 404 and return
    end

    opts = {:text => File.new(f).read, :cache => true}
    if f =~ /css$/ 
      opts[:content_type] = "text/css"
    elsif f =~ /js$/
      opts[:content_type] = "text/javascript"
    else
      render :nothing => true, :status => 404 and return
    end
    render opts
  end

end
