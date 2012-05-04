# admin_data

## Rails 3.0.x

If you are using Rails 3.0.x then use

    gem 'admin_data', '= 1.1.14'

## Rails 3.1.x

If you are using Rails 3.1.x then use

    gem 'admin_data', '= 1.2.1'

Also add following lines to config/application.rb just below the line that says <tt>config.assets.enabled = true</tt> .

    config.assets.precompile += ['admin_data.css', 'admin_data.js']

Before deploying the code to production execute

    bundle exec rake assets:precompile

## Live Demo

Live demo is available at http://admin-data-demo.heroku.com/admin_data (read only version)

## Docs

Documentation is available at https://github.com/bigbinary/admin_data/wiki

## Tests

To execute tests for this gem <tt>cd test/rails_root</tt> and read the instructions mentioned at README.md there.

## License

Released under [MIT](http://github.com/jquery/jquery/blob/master/MIT-LICENSE.txt) License
