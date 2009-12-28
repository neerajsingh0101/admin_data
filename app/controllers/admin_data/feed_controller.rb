class AdminData::FeedController < AdminData::BaseController

  unloadable

  before_filter :ensure_is_allowed_to_view_feed

  def index
    render :text => "usage: http://localhost:3000/admin_data/feed/user" and return if params[:klasss].blank?
    @klasss = params[:klasss]

    begin
      @klass = @klasss.camelize.constantize
    rescue NameError => e
      render :text => "No constant was found with name #{params[:klasss]}" and return
    end
  end

  private

  def ensure_is_allowed_to_view_feed
    return if Rails.env.development? || Rails.env.test?
    if AdminDataConfig.setting[:feed_authentication_user_id].blank? 
      render :text => 'No user id has been supplied for feed' and return
    end

    if AdminDataConfig.setting[:feed_authentication_password].blank? 
      render :text => 'No password has been supplied for feed' and return
    end

    authenticate_or_request_with_http_basic do |id, password|
      id == AdminDataConfig.setting[:feed_authentication_user_id] && password == AdminDataConfig.setting[:feed_authentication_password]
    end
  end

end
