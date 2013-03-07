module AdminData
  class Engine < ::Rails::Engine
    isolate_namespace AdminData

    initializer "admin_data precompile hook" do |app|
      app.config.assets.precompile += [
        'advance_search/*',
        'analytics/*',
        'misc/*',
        'vendor/*',
        'vendor/jquery-ui-1.7.2.custom.css',
        'admin_data.js',
        'admin_data.css'
      ]
    end
  end
end
