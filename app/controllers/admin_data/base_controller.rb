class AdminData::BaseController < ApplicationController

  unloadable

  helper_method :admin_data_is_allowed_to_update?

  layout 'admin_data'

  include AdminData::Chelper

  before_filter :build_klasses, :build_drop_down_for_klasses, :check_page_parameter, :prepare_drop_down_klasses

  attr_reader :klass
  attr_reader :model

  private

  def prepare_drop_down_klasses
    k = params[:klass] || ''
    @drop_down_url = "http://#{request.host_with_port}/admin_data/quick_search/#{CGI.escape(k)}"
  end

  def ensure_is_allowed_to_view
    render :text => '<h2>not authorized</h2>', :status => :unauthorized unless admin_data_is_allowed_to_view?
  end

  def ensure_is_allowed_to_view_model
    render :text => 'not authorized', :status => :unauthorized unless admin_data_is_allowed_to_view_model?
  end

  def ensure_is_allowed_to_update
    render :text => 'not authorized', :status => :unauthorized unless admin_data_is_allowed_to_update?
  end

  def ensure_is_allowed_to_update_model
    render :text => 'not authorized', :status => :unauthorized unless admin_data_is_allowed_to_update_model?
  end

  def ensure_is_allowed_to_view_feed
    render :text => 'not authorized', :status => :unauthorized unless AdminData::Util.is_allowed_to_view_feed?(self)
  end

  def get_class_from_params
    begin
      @klass = AdminData::Util.camelize_constantize(params[:klass])
    rescue TypeError => e # in case no params[:klass] is supplied
      Rails.logger.debug 'no params[:klass] was supplied'
      redirect_to admin_data_index_path
    rescue NameError # in case wrong params[:klass] is supplied
      Rails.logger.debug 'wrong params[:klass] was supplied'
      redirect_to admin_data_index_path
    end
  end

  def build_klasses
    unless defined? $admin_data_klasses
      model_dir = File.join(RAILS_ROOT,'app','models')
      model_names = Dir.chdir(model_dir) { Dir["**/*.rb"] }
      klasses = get_klass_names(model_names)
      filtered_klasses = remove_klasses_without_table(klasses).sort_by {|r| r.name.underscore}
      klasses_with_security_clearance = filtered_klasses.select do |klass_local|
        @klass = klass_local
        admin_data_is_allowed_to_view_model?
      end
      $admin_data_klasses = klasses_with_security_clearance
    end
    @klasses = $admin_data_klasses
  end

  def remove_klasses_without_table(klasses)
    klasses.select { |k| k.ancestors.include?(ActiveRecord::Base) &&
    k.connection.table_exists?(k.table_name) }
  end

  def get_klass_names(model_names)
    model_names.inject([]) do |output, model_name|
      klass_name = model_name.sub(/\.rb$/,'').camelize
      begin
        output << AdminData::Util.constantize_klass(klass_name)
      rescue Exception => e
        Rails.logger.debug e.message
      end
      output
    end
  end

  def build_drop_down_for_klasses
    @drop_down_for_klasses = @klasses.inject([]) do |result,klass|
      result << [klass.name.underscore, admin_data_search_url(:klass => klass.name.underscore)]
    end
  end

  def check_page_parameter
    # Got hoptoad error because of url like http://localhost:3000/admin_data/User/advance_search?page=http://201.134.249.164/intranet/on.txt?
    if params[:page].blank? || (params[:page] =~ /\A\d+\z/)
      # proceed
    else
      render :text => 'Invalid params[:page]', :status => :unprocessable_entity
    end
  end

end
