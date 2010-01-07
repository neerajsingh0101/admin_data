#
# Usage :
# rake admin_data:validate_models_bg RAILS_ENV='development' KLASSES='Country,EeeSociety,PhoneNumber,Website,Car,User' TID='20100107095100'
#
require 'fileutils'
namespace :admin_data do
  desc "Run model valiations"
  task :validate_models_bg => :environment do
    tid = ENV['TID']
    raise "tid is blank" if tid.blank?

    klasses = ENV['KLASSES']
    klasses.split(',').each do |klasss|
      puts "processing #{klasss.inspect}"
      klass = AdminData::Util.constantize_klass(klasss)
      name = klass.name
      raise 'name is blank' if name.blank?
      
      AdminData::Util.write_to_validation_file(tid, 'processing.txt', 'a', name)
      errors = []
      number_of_records = klass.send(:count)
      index = 0
      klass.paginated_each(:order => klass.primary_key) do |record|
        index = index + 1
        s = "processed #{index} of #{number_of_records} #{name} records"
        AdminData::Util.write_to_validation_file(tid, 'processing.txt', 'a', s)
        unless record.valid?
          a = []
          a << klass.name
          a << record.id
          a << record.errors.full_messages
          errors << a
        end
      end
      if errors.any?
        bad_file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid , 'bad.txt')
        errors.each { |error| File.open(bad_file, 'a') {|f| f.puts(error.join(' | ')) } }
      else
        good_file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid , 'good.txt')
        s = "#{klass.name} | #{klass.send(:count)} records: all valid"
        File.open(good_file, 'a') {|f| f.puts(s)}
      end
    end

    done_file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid , 'done.txt')
    File.open(done_file, 'a') {|f| f.puts('') }
  end
end
