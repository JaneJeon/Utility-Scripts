# keeps track of pills you need to take and the history
# @author: Jane Jeon

require 'sqlite3'

# -------------------------- begin class definition --------------------------- #

class Pill
  def initialize(name, num, freq)
    @name = name
    @num = num
    @freq = freq
  end

  attr_accessor :name, :num, :freq
end

# --------------------------- end class definition ---------------------------- #

# ------------------------- begin methods definition -------------------------- #

def positive(input)
  %w(yes y yep yeah).include? input.downcase
end

# the accurate way to get the date, accounting for dst
def now
  time_segs = Time.now.getlocal('-05:00').to_s.split.first.split('-')
  if Time.local(time_segs[0], time_segs[1], time_segs[2]).dst?
    (Time.now.getlocal('-05:00') + 60 * 60).to_s.split.first
  else
    Time.now.getlocal('-05:00').to_s.split.first
  end
end

def pill_names
  db = SQLite3::Database.open 'pills.sqlite'
  current_pills_output = 'Current pills:'
  
  current_pills = db.execute 'SELECT Name FROM Pills'

  # because the above query returns array of array, I need to unpack twice
  current_pills.each do |p1|
    p1.each do |p2|
      current_pills_output << ' ' + p2 + ','
    end
  end
  
  db.close
  
  current_pills_output.chop
end

def pills_list
  db = SQLite3::Database.open 'pills.sqlite'
  pills_list = []

  # read through the database and collect pills info
  result_set = db.execute 'SELECT * FROM Pills'

  result_set.each do |row|
    pills_list << Pill.new(row[0], row[1], row[2])
  end
  
  db.close
  
  pills_list
end

def pills_to_take(rollback)
  db = SQLite3::Database.open 'pills.sqlite'
  result = []

  pills_list.each do |pill|
    result_set = db.execute "SELECT Date FROM Log WHERE Name = '#{pill.name}' 
                            ORDER BY Date DESC LIMIT 1"

    result << pill if result_set.empty?
    
    result_set.each do |strip|
      strip.each do |last_taken|
        result << pill if Date.parse(last_taken) + pill.freq <= 
            Date.parse(now) - rollback
      end
    end
  end
  
  db.close
  
  result
end

# method to be used when first adding to an empty database or during updates
def add
  done = false
  pill = '', pill_num = pill_freq = 0
  db = SQLite3::Database.open 'pills.sqlite'

  until done
    # loops to ensure that user is inputting something
    loop do
      puts 'What pill do you need to take?'
      pill = gets.chomp
      break unless pill.empty?
    end
    loop do
      puts 'How many? (number)'
      pill_num = gets.chomp.to_i
      break if pill_num != 0
    end
    loop do
      puts 'How often? (days)'
      pill_freq = gets.chomp.to_i
      break if pill_freq != 0
    end

    db.execute "INSERT INTO Pills VALUES('#{pill}', #{pill_num}, #{pill_freq})"

    puts 'Is there anything else to add?'
    input = gets.chomp
    done = true if input.empty? || !positive(input)
  end

  db.close
end

def delete
  done = false
  db = SQLite3::Database.open 'pills.sqlite'

  until done
    puts pill_names
    
    loop do
      puts 'What pill are you not taking anymore?'
      pill_name = gets.chomp

      db.execute "DELETE FROM Pills WHERE Name = '#{pill_name}'"

      break unless pill_name.empty?
    end

    puts 'Is there anything else to delete?'
    input = gets.chomp
    done = true if input.empty? || !positive(input)
  end

  db.close
end

def update
  done = false
  pill = '', to_update = ''
  db = SQLite3::Database.open 'pills.sqlite'

  name = %w(pill, name, pillname, pill name)
  num = %w(quantity, num, number, how many, amount)
  freq = %w(freq, frequency, how often, daily)

  until done
    puts pill_names
    
    loop do
      puts 'What pill do you need to update?'
      pill = gets.chomp
      break unless pill.empty?
    end
    loop do
      puts 'What to update?'
      to_update = gets.chomp
      break unless to_update.empty?
    end

    case to_update.downcase
      when *name
        new_name = ''
        loop do
          puts 'What\'s the new name for the pill?'
          new_name = gets.chomp
          break unless new_name.empty?
        end
        
        db.execute "UPDATE Pills SET Name = '#{new_name}' WHERE Name = '#{pill}'"
      when *num
        new_num = 0
        loop do
          puts 'How many do you need to take now?'
          new_num = gets.chomp.to_i
          break if new_num != 0
        end
        
        db.execute "UPDATE Pills SET Amount = #{new_num} WHERE Name = '#{pill}'"
      when *freq
        new_freq = 0
        loop do
          puts 'How often do you need to take now?'
          new_freq = gets.chomp.to_i
          break if new_freq != 0
        end
        
        db.execute "UPDATE Pills SET Frequency = #{new_freq} WHERE Name = 
                    '#{pill}'"
      else
        puts 'u wot?'
    end

    puts 'Is there anything else to update?'
    input = gets.chomp
    done = true if input.empty? || !positive(input)
  end

  db.close
end

def update_dialog
  done = false

  update_ = %w(update u)
  add_ = %w(add a)
  delete_ = %w(delete d del)

  until done
    puts 'Update/Add/Delete prescription: [u/a/d]'

    input = gets.chomp.split.first
    input.downcase unless input.nil?

    case input
      when *update_
        update
      when *add_
        add
      when *delete_
        delete
      else
        break
    end

    puts 'Done changing prescription?'
    done_input = gets.chomp
    done = true if done_input.empty? || positive(done_input)
  end
end

# -------------------------- end methods definition --------------------------- #

# ---------------------------- begin main program ----------------------------- #

# if database doesn't exist, opening will simply create a new one
db = SQLite3::Database.open 'pills.sqlite'

rollback = 0
rollback = 1 if ARGV[0].downcase.eql?('rollback')
ARGV.clear

db.execute 'CREATE TABLE IF NOT EXISTS
            Pills(Name TEXT, Amount INTEGER, Frequency INTEGER)'
db.execute 'CREATE TABLE IF NOT EXISTS Log(Name TEXT, Amount INTEGER, Date TEXT)'

# first check if there are any records in Pills table
add if db.execute('SELECT count(*) FROM Pills').to_s.eql?'[[0]]'

puts ''
pills = pills_to_take(rollback)

# display the last day of pills taken
last_day = db.execute 'SELECT date FROM log ORDER BY date DESC LIMIT 1'
puts "Pill last taken on #{last_day[0][0].tr('"', '')}\n\n"

# display current pills info
if pills.count == 1
  puts 'Pill to take today:'
elsif pills.count > 1
  puts 'Pills to take today:'
end

unless pills.empty?
  pills.each do |pill|
    if pill.freq == 1
      puts "#{pill.num} #{pill.name} every day"
    else
      puts "#{pill.num} #{pill.name} every #{pill.freq} days"
    end
  end

  puts ''
end

# update dialog
puts 'Any change in prescription?'
response = gets.chomp

if positive response
  update_dialog

  # update pills list
  pills = pills_to_take(rollback)
end

# menu dialog
if pills.empty?
  puts "You have no pills to take today.\n\n"
else
  puts 'Did you take your pill today?'
  response = gets.chomp

  if response.empty? || positive(response)
    # log that I have taken such and such pills today onto the database
    pills.each do |pill|
      db.execute "INSERT INTO Log VALUES('#{pill.name}', #{pill.num}, 
                  '#{Date.parse(now) - rollback}')"
    end

    puts "Good job!\n\n"
  else
    puts "Go take your pills for today.\n\n"
  end
end

db.close