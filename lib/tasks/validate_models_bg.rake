#
# Usage :
# rake admin_data:validate_models_bg RAILS_ENV='development' KLASSES='Country,PhoneNumber,Website' TID='20100107095100'
#
require 'fileutils'
namespace :admin_data do
  desc "Run model valiations"
  task :validate_models_bg => :environment do
    begin
      usage = %Q{ rake admin_data:validate_models_bg RAILS_ENV='development' KLASSES='Country,EeeSociety,PhoneNumber,Website,Car,User' TID='20100107095100' }
      usage = ' Usage: ' + usage
      tid = ENV['TID'].try(:to_s)
      raise "tid is blank. #{usage} " if tid.blank?

      klasses = ENV['KLASSES']
      klasses.split(',').compact.each { |klasss| AdminData::RakeUtil.process_klass(klasss, tid) }

      AdminData::Util.write_to_validation_file('', 'a', tid,'done.txt')
    rescue Exception => e
      AdminData::Util.write_to_validation_file(AdminData::Util.exception_info(e), 'a', 'rake_errors.txt')
    end
  end
end
