module AdminData
  class ApplicationController < ::ApplicationController

    layout 'admin_data'

    before_filter :ensure_is_allowed_to_view

    helper_method :is_allowed_to_update?


    before_filter :build_klasses, 
      :build_drop_down_for_klasses, 
      :check_page_parameter, 
      :prepare_drop_down_klasses

    attr_reader :klass

    protected

    self.config.asset_path = lambda {|asset| "/admin_data/public#{asset}"}

    private

    def prepare_drop_down_klasses
      k = params[:klass] || ''
      @drop_down_url = "http://#{request.host_with_port}/admin_data/quick_search/#{CGI.escape(k)}"
    end

    def ensure_is_allowed_to_view
      render :text => 'not authorized' unless is_allowed_to_view?
    end

    def ensure_is_allowed_to_update
      render :text => 'not authorized' unless is_allowed_to_update?
    end

    def get_class_from_params
      begin
        @klass = Util.camelize_constantize(params[:klass])
      rescue TypeError => e # in case no params[:klass] is supplied
        render :text => 'wrong params[:klass] was supplied' and return
      rescue NameError # in case wrong params[:klass] is supplied
        render :text => 'wrong params[:klass] was supplied' and return
      end
    end

    def build_klasses
      @klasses = _build_all_klasses
    end

    def _build_all_klasses
      if defined? $admin_data_all_klasses
        return $admin_data_all_klasses
      else
        model_dir = File.join(Rails.root, 'app', 'models')
        model_names = Dir[ File.join(model_dir, '**', '*.rb').to_s ]
        model_names.map! {|item| item.sub(model_dir,'').sub(/^\//,'').sub(/\.rb$/,'').camelize.gsub(/\//,'::') }

        klasses = get_klass_names(model_names)
        $admin_data_all_klasses = remove_klasses_without_table(klasses).sort_by {|r| r.name.underscore}
      end
    end

    def remove_klasses_without_table(klasses)
      klasses.select { |k| k.ancestors.include?(ActiveRecord::Base) && k.connection.table_exists?(k.table_name) }
    end

    def get_klass_names(model_names)
      model_names.inject([]) do |output, model_name|
        klass_name = model_name.sub(/\.rb$/,'').camelize
        begin
          klass = Util.constantize_klass(klass_name)
          output << klass if klass.to_s == klass_name
        rescue Exception => e
          Rails.logger.debug e.message
        end
        output
      end
    end

    def build_drop_down_for_klasses
      @drop_down_for_klasses = ModelFinder.models.inject([]) do |result, klass|
        result << [klass, search_url(:klass => klass)]
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

    def per_page
      AdminData.config.number_of_records_per_page
    end

    def is_allowed_to_view?
      AdminData.config.is_allowed_to_view.call(self)
    end

    def is_allowed_to_update?
      AdminData.config.is_allowed_to_update.call(self)
    end

  end
end
