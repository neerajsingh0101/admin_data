class AdminData::FeedController < AdminData::BaseController

  unloadable

  before_filter :ensure_is_allowed_to_view_feed

  def index
    render :text => "Usage: http://localhost:3000/admin_data/feed/<model name>" and return if params[:klasss].blank?

    begin
      @klass = AdminData::Util.camelize_constantize(params[:klasss])
    rescue NameError => e
      render :text => "No constant was found with name #{params[:klasss]}" and return
    end
  end

end
