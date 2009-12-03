class AdminData::FeedController < AdminData::BaseController

  unloadable

  before_filter :ensure_is_allowed_to_view_feed

  def index
    render :text => "usage: http://localhost:3000/admin_data/feed/user" and return if params[:klasss].blank?
    @klasss = params[:klasss]

    @klass = @klasss.camelize.constantize
  end

end
