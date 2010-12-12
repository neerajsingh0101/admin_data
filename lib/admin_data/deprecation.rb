class AdminData::Config

  cattr_accessor :setting

  def self.set=(input = {})

msg=<<EOF

AdminData API has changed in version 1.1 .

The changes are very minor.

Instead of

AdminData::Config.set = {
 :find_conditions => ....
}

Now you need to write in following style

AdminData.config do |config|
 config.find_conditions = ...
end

Please refer to documentation at https://github.com/neerajdotname/admin_data/wiki/Customizing-admin_data-for-a-Rails-3-application for more information.

EOF

   raise msg
  end

end
