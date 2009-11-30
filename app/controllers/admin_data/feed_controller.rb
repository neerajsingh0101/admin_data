class AdminData::FeedController < AdminData::BaseController

  def index
    @klasss = params[:klasss]
    @klass = @klasss.camelize.constantize
  end

end
