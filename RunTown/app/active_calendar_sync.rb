require 'rubygems'
require 'googlecalendar' # this gem is no longer maintained. should move to google api gem
require 'rest-client'
require 'json'
require 'cgi'
require 'nokogiri'

ACTIVE_API_KEY = 'FILL_ME_OUT'

# Change the Below Values to change your active.com search
KEY_WORDS = nil
EVENT_TYPE = nil # this value is comma delimited
GOOGLE_USER = 'GOOGLE_EMAIL'
GOOGLE_PASS = 'GOOGLE_PASS'
CALENDAR_NAME = nil # nil is the default calendar

class ActiveSync
  include Googlecalendar

  # Util method to build the active api url
  def build_active_url(api_key,args={})
    root_url = "http://api.amp.active.com/search?api_key=#{api_key}&v=json"

    args = { :page => 1, :page_size => 50, :radius => 30, :location => "boston,ma,us", :key_words => "5k" }.merge args

    radius = args[:radius]
    location = args[:location]
    key_words = args[:key_words]  # not used if :channel is provided
    page = args[:page]
    page_size = args[:page_size]
    channel = args[:channel]

    if channel.nil?
      url = "#{root_url}&r=#{radius}&l=#{location}&k=#{key_words}&page=#{page}&num=#{page_size}"
    else
      url = "#{root_url}&r=#{radius}&l=#{location}&m=meta:channel=#{channel}&page=#{page}&num=#{page_size}"
    end

    p "Executing: #{url}"
    url
  end

  # method used to retrieve active api event data and add them to the calendar
  # Note: This method does not 'sync'. It only adds events to calendars, and does not check if the event already exists
  def sync
    begin
      page_num = 1
      page_size = 100
      end_index = page_size
      total_number_of_results = -1

      event_counter = 0
      # FYI Requests are throttled a 2 per sec, and 10000 per day

      g = GData.new
      g.login(GOOGLE_USER, GOOGLE_PASS)

      while total_number_of_results < 0 || end_index <= total_number_of_results

        # no authentication is required (other than the API Key), since the information is publicly available
        get_request = RestClient::Resource.new build_active_url(ACTIVE_API_KEY,
                                                                {:page => page_num, :page_size => page_size,
                                                                 :channel => EVENT_TYPE, :key_words => KEY_WORDS})

        response = get_request.get
        event_data = JSON.parse response.body

        end_index = event_data['endIndex']
        total_number_of_results = event_data['numberOfResults'] unless total_number_of_results > 0

        # The Active API documentation is lacking in terms of what data is returned, so it is best
        # to just execute a request and examine the fields coming back

        events = event_data['_results']
        events.each do |event|
          race_name = event['title']

          meta_data = event['meta']
          event_id = meta_data['eventId']

          re = /<("[^"]*"|'[^']*'|[^'">])*>/
          description = meta_data['description']
          description.gsub!(re, '') unless description.nil? # remove html tags from description

          registration_url = meta_data['registrationUrl']
          event_url = meta_data['eventUrl']

          city = meta_data['city']
          state = meta_data['eventState']
          address = meta_data['eventAddress']

          start_time = meta_data['startTime']
          start_date = meta_data['startDate']
          end_time = meta_data['endTime']
          end_date = meta_data['endDate']

          add_event(g, CALENDAR_NAME, {
            :title => CGI.escape_html(race_name),
            :content => CGI.escape_html("#{description}\nRegistration: #{registration_url}\nEvent Url: #{event_url}"),
            :author => 'pub.active',
            :email => 'pub.active@gmail.com',
            :where => CGI.escape_html("#{address}, #{city}, #{state}"),
            :startTime => CGI.escape_html("#{start_date}T#{start_time}"),
            :endTime => CGI.escape_html("#{end_date}T#{end_time}")
          })
          event_counter+=1
        end

        page_num += 1

      end

    rescue Exception => e
      p "Exception #{e}"
      p e.backtrace
    end

  end

  def add_event(gdata,calendar=nil,event={})
    unless event.size < 1
      if calendar.nil?
        #result = gdata.new_event(event)
      else
        #result = gdata.new_event(event, calendar)
      end
    end
  end
end

ActiveSync.new.sync

