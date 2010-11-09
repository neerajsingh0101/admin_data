class AdminData::FeedController < AdminData::BaseController

  unloadable

  before_filter :ensure_is_allowed_to_view_feed

  def index
    render :text => "Usage: http://localhost:3000/admin_data/feed/<model name>" and return if params[:klasss].blank?

    begin
      @klass = AdminData::Util.camelize_constantize(params[:klasss])
      @title = "Feeds from admin_data #{@klass.name}"
      @description = "feeds from AdminData #{@klass.name}"
      @records = @klass.find(:all, :order => "#{@klass.primary_key} desc", :limit => 100)
    rescue NameError => e
      render :text => "No constant was found with name #{params[:klasss]}" and return
    end
  end

  private

  def ensure_is_allowed_to_view_feed
    render :text => 'not authorized' unless AdminData::Util.is_allowed_to_view_feed?(self)
  end

end
