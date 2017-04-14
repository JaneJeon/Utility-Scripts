# Alarm clock in which I can set multiple alarms, view status, and cancel them
# Supposed to be reliable, unlike the f***ing MATLAB version
# Instead of alarm sound, play the latest episode of BBC world podcast at max 
# volume when it's time to wake up so I can get the news
# edit: I added the option for The Intercept, which I never knew was a podcast.
# @author: Jane Jeon
# TODO: support multiple alarms
# TODO: write unit tests for the time-checking options to make sure that 
# they're working properly

require 'open-uri'

# ------------------------------ begin methods ------------------------------- #

def sleep_timer(command)
  case command.size
    when 1
      # XhYY
      h_mark = command[0].index('h')
      hours = command[0][0...h_mark].to_i
      minutes = command[0][(h_mark + 1)...command[0].size].to_i
      
      return 3600 * hours + 60 * minutes
    when 2
      # either X hour or X min
      if command[1].eql?'hour'
        return 3600 * command[0].to_i
      else
        return 60 * command[0].to_i
      end
    when 4
      # X hour X min
      return 3600 * command[0].to_i + 60 * command[2].to_i
    else
      puts 'Invalid format!'
      return 0
  end
end

def past_now(hour, min)
  (Time.now.hour < hour || (Time.now.hour == hour && Time.now.min < min)) ?
      true :
      false
end

def wake_timer(command)
  index = command[0].index(':')
  
  if index.nil?
    # only the hour is given
    return 0 unless command[0].split(/(\D+)/)[1].nil?
    hour = command[0].to_i
    return 0 if hour > 12
    
    if command.size == 1
      # wake X o'clock
      hour += 12 if hour <= Time.now.hour
      return (hour - Time.now.hour) * 3600 - Time.now.min * 60
    elsif command.size == 2
      # wake X AM/PM
      hour += 12 if command[1].eql?('pm')
      hour += 24 if hour <= Time.now.hour
      return (hour - Time.now.hour) * 3600 - Time.now.min * 60
    else
      return 0
    end
  else
    hour = command[0][0...index].to_i
    min = command[0][index+1...command[0].size].to_i
    
    if command.size == 1
      # X:XX or XX:XX
      return 0 if (hour > 24 || min > 60)
      
      unless past_now(hour, min)
        (hour <= 12) ?
            until past_now(hour, min)
              hour += 12
            end :
            hour += 24
      end
      
      return (hour - Time.now.hour) * 3600 + (min - Time.now.min) * 60
    elsif command.size == 2
      # X:XX AM/PM
      return 0 if (hour > 12 || min > 60)

      hour += 12 if command[1].eql?('pm')
      hour += 24 unless past_now(hour, min)
      return (hour - Time.now.hour) * 3600 + (min - Time.now.min) * 60
    else
      return 0
    end
  end
end

# ------------------------------- end methods -------------------------------- #

# ---------------------------- begin main program ---------------------------- #

# regularly paste on chrome to see if the format of RSS has changed or not
FEED_LINK = %w(http://www.bbc.co.uk/programmes/p02nq0gn/episodes/downloads
.rss https://feeds.feedburner.com/InterceptedWithJeremyScahill)
set_time = '', duration = 0
done = false
station = ['BBC', 'The Intercept']
station_id = 0

puts "Supported time formats:
sleep X hour X min | sleep X hour | sleep X min | sleep XhYY
wake X:XX | wake XX:XX | wake X (o'clock) | wake X AM/PM | wake X:XX AM/PM
[change] station: [BBC]/The Intercept\n\n"

until done
  loop do
    puts 'Set alarm:'
    set_time = gets.chomp
    break unless set_time.empty?
  end
  
  time_command = set_time.downcase.split
  
  case time_command.first
    when 'sleep'
      # remove first word before passing into methods
      duration = sleep_timer time_command.drop(1)
      done = true unless duration == 0
    when 'wake'
      duration = wake_timer time_command.drop(1)
      done = true unless duration == 0
    when 'change'
      station_id = (station_id + 1) % 2
      puts "Station: #{station[station_id]}"
    else
      puts "Supported commands: sleep, wake\n"
  end
end

# wait until desired time
sleep duration

# load in XML from RSS feed
page_string = open(FEED_LINK[station_id]) { |f| f.read }

# indexing XML for date
start_idx = page_string.index('<pubDate>')
end_idx = page_string.index('</pubDate>')
date = page_string[(start_idx + '<pubDate>'.length)...end_idx]

puts "Here's the news for #{date}"

# indexing XML for latest mp3 link
start_idx = page_string.index('<enclosure url="')
end_idx = page_string.index('" length="')
media_url = page_string[(start_idx + '<enclosure url="'.length)...end_idx]

# save audio file
open('audio.mp3', 'wb') { |file| file << open(media_url).read }

# afplay is a mac-specific program. use system() or pid for windows.
`afplay audio.mp3`

# TODO: fix alarm