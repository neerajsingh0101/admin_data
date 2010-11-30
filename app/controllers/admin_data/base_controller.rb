module AdminData
  class BaseController < ApplicationController

    unloadable

    before_filter :ensure_is_allowed_to_view

    helper_method :admin_data_is_allowed_to_update?

    layout 'admin_data'

    include Chelper

    before_filter :build_klasses, :build_drop_down_for_klasses, :check_page_parameter, :prepare_drop_down_klasses

    attr_reader :klass, :model

    protected

    self.config.asset_path = lambda {|asset| "/admin_data/public#{asset}"}

    private

    def prepare_drop_down_klasses
      k = params[:klass] || ''
      @drop_down_url = "http://#{request.host_with_port}/admin_data/quick_search/#{CGI.escape(k)}"
    end

    def ensure_is_allowed_to_view
      render :text => 'not authorized' unless admin_data_is_allowed_to_view?
    end

    def ensure_is_allowed_to_view_klass
      render :text => 'not authorized' unless admin_data_is_allowed_to_view_klass?
    end

    def ensure_is_allowed_to_update
      render :text => 'not authorized' unless admin_data_is_allowed_to_update?
    end

    def ensure_is_allowed_to_update_klass
      render :text => 'not authorized' unless admin_data_is_allowed_to_update_klass?
    end


    def get_class_from_params
      begin
        @klass = Util.camelize_constantize(params[:klass])
      rescue TypeError => e # in case no params[:klass] is supplied
        Rails.logger.debug 'no params[:klass] was supplied'
        redirect_to admin_data_index_path
      rescue NameError # in case wrong params[:klass] is supplied
        Rails.logger.debug 'wrong params[:klass] was supplied'
        redirect_to admin_data_index_path
      end
    end

    def build_klasses
      # if is_allowed_to_view_klass option is passed then global constant can't be used since
      # list of klasses need to be built for each user. It will slow down the speed a bit since
      # every single the list needs to be built
      if Config.setting[:is_allowed_to_view_klass]
        @klasses = _build_custom_klasses
      else
        @klasses = _build_all_klasses
      end
    end

    def _build_all_klasses
      if defined? $admin_data_all_klasses
        return $admin_data_all_klasses
      else
        model_dir = File.join(Rails.root, 'app', 'models')
        model_names = Dir.chdir(model_dir) { Dir["*.rb"] }
        klasses = get_klass_names(model_names)
        $admin_data_all_klasses = remove_klasses_without_table(klasses).sort_by {|r| r.name.underscore}
      end
    end

    def _build_custom_klasses
      _build_all_klasses.compact.select do |klass_local|
        @klass = klass_local
        admin_data_is_allowed_to_view_klass?
      end
    end

    def remove_klasses_without_table(klasses)
      klasses.select { |k| k.ancestors.include?(ActiveRecord::Base) && k.connection.table_exists?(k.table_name) }
    end

    def get_klass_names(model_names)
      model_names.inject([]) do |output, model_name|
        klass_name = model_name.sub(/\.rb$/,'').camelize
        begin
          output << Util.constantize_klass(klass_name)
        rescue Exception => e
          Rails.logger.debug e.message
        end
        output
      end
    end

    def build_drop_down_for_klasses
      @drop_down_for_klasses = @klasses.inject([]) do |result, klass|
        result << [klass.name.underscore, admin_data_search_url(:klass => klass.name.underscore)]
      end
    end

    def check_page_parameter
      # Got hoptoad error because of url like
      # http://localhost:3000/admin_data/User/advance_search?page=http://201.134.249.164/intranet/on.txt?
      if params[:page].blank? || (params[:page] =~ /\A\d+\z/)
        # proceed
      else
        render :text => 'Invalid params[:page]', :status => :unprocessable_entity
      end
    end

  end
end
