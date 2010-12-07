module AdminData

  class FeedController < ApplicationController

    def index
      render :text => "Usage: http://localhost:3000/admin_data/feed/<model name>" and return if params[:klasss].blank?

      begin
        @klass = Util.camelize_constantize(params[:klasss])
        @title = "Feeds from admin_data #{@klass.name}"
        @description = "feeds from AdminData #{@klass.name}"
        @records = @klass.find(:all, :order => "#{@klass.primary_key} desc", :limit => 100)
      rescue NameError => e
        render :text => "No constant was found with name #{params[:klasss]}" and return
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

      stored_userid = AdminData.config.feed_authentication_user_id
      stored_password = AdminData.config.feed_authentication_password
      perform_basic_authentication(stored_userid, stored_password, controller)
    end

    def perform_basic_authentication(stored_userid, stored_password, controller)
      controller.authenticate_or_request_with_http_basic do |input_userid, input_password|
        (input_userid == stored_userid) && (input_password == stored_password)
      end
    end

  end

end
