# keeps track of pills you need to take and the history
# @author: Jane Jeon
# TODO: check previous records and date frequency

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

def pill_names
  db = SQLite3::Database.open 'pills.db'
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
  db = SQLite3::Database.open 'pills.db'
  pills_list = []

  # read through the database and collect pills info
  result_set = db.execute 'SELECT * FROM Pills'

  result_set.each do |row|
    pills_list << Pill.new(row[0], row[1], row[2])
  end
  
  db.close
  
  pills_list
end

# method to be used when I'm first adding to an empty database or during updates
def add
  done = false
  pill = '', pill_num = pill_freq = 0
  db = SQLite3::Database.open 'pills.db'

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

  #db.close
end

def delete
  done = false
  db = SQLite3::Database.open 'pills.db'

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
  db = SQLite3::Database.open 'pills.db'

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

  update = %w(update u)
  adding = %w(add a)
  delete = %w(delete d del)

  until done
    puts 'Update/Add/Delete prescription: [u/a/d]'

    input = gets.chomp.split.first
    input.downcase unless input.nil?

    case input
      when *update
        update()
      when *adding
        add()
      when *delete
        delete()
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

db = SQLite3::Database.open 'pills.db'

db.execute 'CREATE TABLE IF NOT EXISTS
            Pills(Name TEXT, Amount INTEGER, Frequency INTEGER)'
db.execute 'CREATE TABLE IF NOT EXISTS Log(Name TEXT, Amount INTEGER, Date TEXT)'

# first check if there are any records in Pills table
add if db.execute('SELECT count(*) FROM Pills').to_s.eql?'[[0]]'

puts ''
pills = pills_list

# display current pills info
if pills.count == 1
  puts 'Pill to take:'
else
  puts 'Pills to take:'
end

pills.each do |pill|
  if pill.freq == 1
    puts "#{pill.num} #{pill.name} every day"
  else
    puts "#{pill.num} #{pill.name} every #{pill.freq} days"
  end
end

puts ''

# update dialog
puts 'Any change in prescription?'
response = gets.chomp

if positive response
  update_dialog

  # update pills list
  pills = pills_list
end

# menu dialog
puts 'Did you take your pill today?'
response = gets.chomp

if response.empty? || positive(response)
  # log that I have taken such and such pills today onto the database
  pills.each do |pill|
    db.execute "INSERT INTO Log
                VALUES('#{pill.name}', #{pill.num}, '#{Date.today}')"
  end

  puts 'Good job!'
else
  puts 'Go take your pills for today.'
end

db.close