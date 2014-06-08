class EventListingWorker

  def perform
    agent = Mechanize.new
    ## Future Events ##
    doc   = agent.get("http://www.baychi.org/calendar")

    events_part = doc.search('.Content-Pane div[@class^=evsum]')

    events_part.each do |part|
      type_name = get_type_name(part.attr('class'))
      content    = part.search('.evdtl').last
      dates      = content.children.detect{|c| c.name == 'b'}.text
      dates_arr  = dates.split(' ')
      start_date = nil
      end_date   = nil
      if dates_arr.size == 3
        date_range = dates_arr[1].split('-')
        start_date = Date.strptime("#{dates_arr[0]} #{date_range[0].to_i}, #{dates_arr[2]}", "%B %d, %Y")
        end_date   = Date.strptime("#{dates_arr[0]} #{date_range[1].to_i}, #{dates_arr[2]}", "%B %d, %Y") if date_range.size == 2
      end
      location   = content.children.detect{|c| c.class.name == 'Nokogiri::XML::Text'}.text.gsub(/\n/, '')
      header    = part.search('.evttl').first
      name      = header.text
      event_url = header.children.attr('href').value
      if event_url.include?("baychi.org")
        res = agent.get("http://www.baychi.org/program")
        para = res.search('.Summary-Pane p')
        loc = para.detect{|p| p.children.children.text == 'Location'}
        org = para.detect{|p| p.children.children.text == 'BayCHI Contact'}
        puts "==#{loc}===#{org}"
        description = res.search('.Content-Pane').last.text
      end
      Event.create(event_name: name, event_type: type_name, event_start_date: start_date, event_end_date: end_date,
        event_location: location, event_url: event_url, event_description: description)
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