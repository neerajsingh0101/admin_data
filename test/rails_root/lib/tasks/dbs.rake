require "fileutils"

namespace :db do

  namespace :use do

    desc 'set database.yml to sqlite3'
    task :sqlite3 do
      file = Rails.root.join('config', 'database.yml')
      orig = Rails.root.join('config', 'database.yml.sqlite3')
      FileUtils.cp(orig, file)
    end

    desc 'set database.yml to pg'
    task :pg do
      file = Rails.root.join('config', 'database.yml')
      orig = Rails.root.join('config', 'database.yml.pg')
      FileUtils.cp(orig, file)
    end

    desc 'set database.yml to mysql'
    task :mysql do
      file = Rails.root.join('config', 'database.yml')
      orig = Rails.root.join('config', 'database.yml.mysql')
      FileUtils.cp(orig, file)
    end


  end
end
