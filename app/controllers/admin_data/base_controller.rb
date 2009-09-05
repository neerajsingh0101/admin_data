class AdminData::BaseController  < ApplicationController

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
      @klass = Object.const_get(params[:klass])
    rescue TypeError => e # in case no params[:klass] is supplied
      Rails.logger.debug 'no params[:klass] was supplied'
      redirect_to admin_data_path
    rescue NameError # in case wrong params[:klass] is supplied
      Rails.logger.debug 'wrong params[:klass] was supplied'
      redirect_to admin_data_path
    end
  end

  def build_klasses
    @klasses = []
    models = []

    model_dir = File.join(RAILS_ROOT,'app','models')
    Dir.chdir(model_dir) { models = Dir["**/*.rb"] }

    models = models.sort

    models.each do |model|
      class_name = model.sub(/\.rb$/,'').camelize
      begin
        # for models/foo/bar/baz.rb
        klass = class_name.split('::').inject(Object){ |klass,part| klass.const_get(part) }
      rescue Exception
      end
      if klass && klass.ancestors.include?(ActiveRecord::Base)  && !@klasses.include?(klass)
        # it is possible that a model doesnot have a table because migration
        # has not been run or
        # migration has deleted the table but the model has not been deleted.
        # So remove those classes from the list
        # I will send a count method to determine if a table is existing or not
        begin
          klass.send(:count)
          @klasses << klass
        rescue ActiveRecord::StatementInvalid  => e
        end
      end
    end
  end


  # can't be extracted to a helper because it uses named routes
  def build_drop_down_for_klasses
    @drop_down_for_klasses = @klasses.inject([]) do |result,klass|
      result << [klass.name,  admin_data_list_url(:klass => klass.name)]
    end
  end

end
