module AdminData

  class FeedController < ApplicationController

    before_filter :ensure_is_allowed_to_view_feed

    def index
      if params[:klasss].blank?
        render :text => "Usage: http://localhost:3000/admin_data/feed/user replace user with your model name"
        return
      end

      begin
        @klass = Util.camelize_constantize(params[:klasss])
        @title = "Feeds from admin_data #{@klass.name}"
        @description = "feeds from AdminData #{@klass.name}"
        @records = @klass.find(:all, :order => "#{@klass.primary_key} desc", :limit => 100)
      rescue NameError
        render :text => "No constant was found with name #{params[:klasss]}"
      end
    end

    private

    def ensure_is_allowed_to_view_feed
      render :text => 'not authorized' unless is_allowed_to_view_feed?(self)
    end

    def is_allowed_to_view_feed?(controller)
      return true if Rails.env.development?

      if AdminData.config.feed_authentication_user_id.blank?
        Rails.logger.info 'No user id has been supplied for feed'
        return false
      elsif AdminData.config.feed_authentication_password.blank?
        Rails.logger.info 'No password has been supplied for feed'
        return false
      end

      userid = AdminData.config.feed_authentication_user_id
      password = AdminData.config.feed_authentication_password
      authenticator = AdminData::Authenticator.new(userid, password)
      authenticator.verify(controller)
    end

  end

end
