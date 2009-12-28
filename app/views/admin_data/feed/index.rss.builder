xml.instruct! :xml, :version=>"1.0"
xml.rss(:version=>"2.0"){
  xml.channel{
    xml.title("Feeds from AdminData #{@klasss}")
    xml.link(request.host_with_port)
    xml.description("feeds from AdminData #{@klasss}")
    xml.language('en-us')
    # FIXME id is hardcoded user Klass.primary_key
    h = {:order => 'id desc', :limit => 100}
    @klass.find(:all, h).each do |record|
      xml.item do
        xml.title("#{@klasss} id: #{record.id}")

        tmp = admin_data_get_label_values_pair_for(record)
        desc = tmp.inject('') do |sum, a|
          sum += "<p>#{a[0]}: #{a[1]}</p>"
        end
        xml.description(desc)
        xml.pubDate(record.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
        xml.link(admin_data_on_k_path(:id => record, :klass => @klasss))
        xml.guid(admin_data_on_k_path(:id => record, :klass => @klasss))
      end
    end
  }
}
