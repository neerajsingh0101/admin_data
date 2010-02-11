class AdminData::RakeUtil

  def self.process_klass(klasss, tid)
    begin
      puts "processing #{klasss.inspect}"
      klass = AdminData::Util.constantize_klass(klasss)

      AdminData::Util.write_to_validation_file(klass.name, 'a', tid, 'processing.txt')
      number_of_records = klass.send(:count)
      index = 0
      all_records_are_valid = true

      klass.paginated_each(:order => klass.primary_key) do |record|
        index += 1
        s = "processed #{index} of #{number_of_records} #{name} records"
        AdminData::Util.write_to_validation_file(s, 'a', tid, 'processing.txt')
        unless record.valid?
          all_records_are_valid = false
          error = [klass.name, record.id, record.errors.full_messages]
          AdminData::Util.write_to_validation_file(error.join(' | '), 'a', tid, 'bad.txt')
        end
      end

      if all_records_are_valid
        s = "#{klass.name} | #{klass.send(:count)} records: all valid"
        AdminData::Util.write_to_validation_file(s, 'a', tid, 'good.txt')
      end
    rescue Exception => e
      AdminData::Util.write_to_validation_file(AdminData::Util.exception_info(e), 'a', 'rake_errors.txt')
    end
  end

end
