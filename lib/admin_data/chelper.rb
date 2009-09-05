module AdminData::Chelper

  def per_page
    AdminDataConfig.setting[:will_paginate_per_page]
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

  def admin_data_is_allowed_to_update?
    return true if Rails.env.development? || AdminDataConfig.setting[:update_security_check].call(self)
    false
  end

end
