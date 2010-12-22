xml.instruct! :xml, :version => "1.0"
xml.rss(:version => "2.0" ){
  xml.channel{
    xml.title(@title)
    xml.link(request.host_with_port)
    xml.description(@description)
    xml.language('en-us')
    h = {:order => "#{@klass.primary_key} desc", :limit => 100}
    @records.each do |record|
      xml.item do
        xml.title("#{@klasss} id: #{record.id}")

        desc = AdminData::Util.label_values_pair_for(record, self).inject([]) do |sum, a|
          sum << "<p>#{a[0]}: #{a[1]}</p>"
        end.join

        xml.description(desc)
        d = record.respond_to?(:created_at) ?  record.created_at : Time.now
        xml.pubDate(d.strftime("%a, %d %b %Y %H:%M:%S %z"))
        xml.link(admin_data_url(:id => record, :klass => @klass.name))
        xml.guid(admin_data_url(:id => record, :klass => @klass.name))
      end
    end
  }
}
