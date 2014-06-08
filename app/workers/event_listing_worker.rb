class EventListingWorker

  def perform(page_url)
    agent = Mechanize.new
    ## Future Events ##
    doc   = agent.get(page_url)

    events_part = doc.search('.Content-Pane div[@class^=evsum]')

    events_part.each do |part|
      type_name   = get_type_name(part.attr('class'))
      content     = part.search('.evdtl').last
      start_date  = nil
      end_date    = nil
      location    = nil
      name        = nil
      event_url   = nil
      org_name    = nil
      org_email   = nil
      description = nil
      if content.present?
        dates      = content.children.detect{|c| c.name == 'b'}.try(:text)
        dates_arr  = dates.split(' ')
        if dates_arr.size == 3
          date_range = dates_arr[1].split('-')
          start_date = Date.strptime("#{dates_arr[0]} #{date_range[0].to_i}, #{dates_arr[2]}", "%B %d, %Y")
          end_date   = Date.strptime("#{dates_arr[0]} #{date_range[1].to_i}, #{dates_arr[2]}", "%B %d, %Y") if date_range.size == 2
        end
        location   = content.children.detect{|c| c.class.name == 'Nokogiri::XML::Text'}.try(:text)
        location   = location.gsub(/\n/, '') if location.present?
      end  
      header    = part.search('.evttl').first

      if header.present?
        name      = header.text
        event_url = header.children.attr('href').try(:value)
      end  
      puts "===============#{event_url}"
      if event_url.present? && !event_url.include?("http") 
        puts "=={in envent...}"
        event_url = "http://baychi.org#{event_url}"
        puts "===============#{event_url}"
        res = agent.get(event_url)
        para = res.search('.Summary-Pane p')
        puts "==#{para.inspect}"
        loc = para.detect{|p| p.children.children.text == 'Location' || p.children.children.text == 'LocationDirections'}.try(:text)
        loc = loc.gsub(/\n/,'').gsub(/Location/, '').gsub(/Directions/, '') if loc.present?
        org = para.detect{|p| p.children.children.text.include?('BayCHI Contact')}.try(:text)
        if org.present?
          org_name  = org.split(/\n/)[1]
          org_email = org.split(/\n/)[2]
        end  
        description = res.search('.Content-Pane').to_html
        puts "==ddddddddddddddddddd#{description}"
      end
      event = Event.where("event_name = ? and event_start_date = ? and event_end_date = ?", name, start_date, end_date).first
      if event.present?
        event.update_attributes(event_name: name, event_type: type_name, event_start_date: start_date, event_end_date: end_date, event_location: location, event_url: event_url)
        puts "==#{event.valid?}==#{event.errors.inspect}=======================================================rrrrrrrrrrrrrrrrr"        

      else
        Event.create(event_name: name, event_type: type_name, event_start_date: start_date, event_end_date: end_date, event_location: location, event_url: event_url)
      end
    end

    ## Past Events ##
    #http://www.baychi.org/calendar/past/

    ## RSS ##
    #http://www.baychi.org/rss.xml
    #feed = Feedjira::Feed.fetch_and_parse('http://www.baychi.org/rss.xml')
  end


  private

  def get_type_name(class_name)
    type_name = case class_name
    when 'evsum-gen'
      'generic'
    when 'evsum-pgm'
      'meeting'
    when 'evsum-bof'
      'birds_of_feature'
    when 'evsum-glo'
      'generic_nonlocal'
    when 'evsum-ldr'
      'leadership'
    when 'evsum-acm'
      'acm'
    when 'evsum-sig'
      'sigchi'
    else
      ''
    end
    type_name
  end

end