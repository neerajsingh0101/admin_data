class AdminData::Extension

  def self.show_info(model)
    return []
    klass = model.class
    if klass == User

      if (habtm_klasses = AdminData::ActiveRecordUtil.habtm_klasses_for(klass)).any?
        habtm_klasses.each do |k|
          name = k.columns.map(&:name).include?('name') ? :name : k.primary_key
          data << [ k.table_name, model.send(k.table_name).map{ |e|
            view.link_to(e.send(name), view.admin_data_path(:klass => k, :id => e.send(k.primary_key)))
          }.join(", ").html_safe ]
        end
      end
    end

  end # end of method


end
