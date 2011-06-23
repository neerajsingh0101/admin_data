# Test setup #

    bundle install
    rake db:migrate
    rake db:test:prepare

# Cucumber test #

    bundle exec cucumber

# Unit test #

    ruby -I test test/unit/car_test.rb

# Switch database #

    rake db:use:pg
    rake db:use:sqlite3
    rake db:use:mysql
