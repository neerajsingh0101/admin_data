class AdminData::BaseController  < ApplicationController

  helper_method :admin_data_is_allowed_to_update?

  layout 'admin_data'

  include AdminData::Chelper

  before_filter :ensure_is_allowed_to_view
  before_filter :build_klasses

  private

  def ensure_is_allowed_to_view
    return true if Rails.env.development? || AdminDataConfig.setting[:view_security_check].call(self)
    render :text => '<h2>not authorized</h2>', :status => :unauthorized
  end

  def ensure_is_allowed_to_update
    render :text => 'not authorized', :status => :unauthorized unless admin_data_is_allowed_to_update?
  end

  def get_class_from_params
    begin
      @klass = Object.const_get(params[:klass])
    rescue TypeError => e # in case no params[:klass] is supplied
      Rails.logger.debug 'no params[:klass] was supplied'
      redirect_to admin_data_path
    rescue NameError # in case wrong params[:klass] is supplied
      Rails.logger.debug 'wrong params[:klass] was supplied'
      redirect_to admin_data_path
    end
  end

end
