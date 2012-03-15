module AdminData
  class Engine < Rails::Engine

    initializer "admin_data precompile hook" do |app|
      app.config.assets.precompile += ['admin_data.js', 'admin_data.css']
    end

    rake_tasks do
      #
    end

  end
end
