class AdminData::BaseController < ApplicationController

  helper_method :admin_data_is_allowed_to_update?

  layout 'admin_data'

  include AdminData::Chelper

  before_filter :ensure_is_allowed_to_view , :build_klasses, :build_drop_down_for_klasses

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
      @klass = params[:klass].camelize.constantize
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
      $admin_data_klasses = remove_klasses_without_table(klasses).
                                             sort_by {|r| r.name.underscore}
    end
    @klasses = $admin_data_klasses
  end

  def remove_klasses_without_table(klasses)
    klasses.select { |k| k.ancestors.include?(ActiveRecord::Base) && 
                                                              k.connection.table_exists?(k.table_name) }
  end

  def get_klass_names(model_names)
    model_names.inject([]) do |output, model_name|
      class_name = model_name.sub(/\.rb$/,'').camelize
      begin
        # for models like app/models/foo/bar/baz.rb
         klass = class_name.split('::').inject(Object) do |klass, part| 
            klass.const_get(part) 
         end 
        output << klass
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

end
