module AdminData
  module ModelFinder
    extend self

    def models
      ActiveRecord::Base.send(:subclasses).map do | klass | 
        namespaced_models(klass).push(klass.name) 
      end.flatten.sort
    end

    def namespaced_models(model_klass)
      model_klass.subclasses.map(&:name)
    end
  end
end
