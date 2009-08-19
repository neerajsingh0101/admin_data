module AdminData::Chelper

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
            # it is possible that a model doesnot have a table because migration has not been run or
            # migration has deleted the table but the model has not been deleted. So remove those classes from the list
            # I will send a count method to determine if a table is existing or not
            begin
               klass.send(:count)
               @klasses << klass
            rescue ActiveRecord::StatementInvalid  => e
            end
         end
      end
   end

   def ensure_is_allowed_to_view
      render :text => 'You are not authorized' unless admin_data_is_allowed_to_view?
   end

   def admin_data_is_allowed_to_view?
      return true if Rails.env.development? || Rails.env.test?
      begin
         output = Object.const_get('ADMIN_DATA_VIEW_AUTHORIZATION').call(self)
         Rails.logger.info("Authentication for ADMIN_DATA_VIEW_AUTHORIZATION was called and the result was #{output}")
         return false unless output
      rescue NameError => e
         Rails.logger.info("ADMIN_DATA_VIEW_AUTHORIZATION is not declared. " + e.to_s)
         return false
      end
      true
   end

   def admin_data_is_allowed_to_update?
      return true if Rails.env.development? || Rails.env.test?
      begin
         output = Object.const_get('ADMIN_DATA_UPDATE_AUTHORIZATION').call(self)
         Rails.logger.info("Authentication for ADMIN_DATA_UPDATE_AUTHORIZATION was called and the result was #{output}")
         return false unless output
      rescue NameError => e
         Rails.logger.info("ADMIN_DATA_UPDATE_AUTHORIZATION is not declared. " + e.to_s)
         return false
      end
      true
   end

end
