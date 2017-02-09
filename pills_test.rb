require 'sqlite3'

# ------------------------ begin class definition ----------------------------- #

class Pill
  def initialize(name, num, freq)
    @name = name
    @num = num
    @freq = freq
  end

  attr_accessor :name, :num, :freq
end

# ------------------------- end class definition ------------------------------ #

# ----------------------- begin methods definition ---------------------------- #

def positive(input)
  %w(yes y yep yeah).include? input.downcase
end

# method to be used when I'm first adding to an empty database or during updates
def add
  done = false
  # initialize variables here so they can be accessed outside loops
  pill = '', pill_num = pill_freq = 0

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

    puts 'Anything else?'
    input = gets.chomp
    done = true if input.empty? || !positive(input)
  end
end

# ------------------------ end methods definition ----------------------------- #

# -------------------------- begin main program ------------------------------- #

db = SQLite3::Database.open 'pills.db'

db.execute 'CREATE TABLE IF NOT EXISTS Pills(Name TEXT, Amount INTEGER, Frequency INTEGER)'
db.execute 'CREATE TABLE IF NOT EXISTS Log(Name TEXT, Amount INTEGER, Date TEXT)'

# first check if there are any records in Pills table
if db.execute('SELECT count(*) FROM Pills').to_s.eql?'[[0]]'
  add
end

puts ''
pills_list = []

# read through the database and collect pills info
statement = db.prepare 'SELECT * FROM Pills'
result_set = statement.execute

result_set.each do |row|
  pills_list << Pill.new(row[0], row[1], row[2])
end

# need to close the statement
statement.close

if pills_list.count == 1
  puts 'Pill to take:'
else
  puts 'Pills to take:'
end

pills_list.each do |pill|
  if pill.freq == 1
    puts "#{pill.num} #{pill.name} every day"
  else
    puts "#{pill.num} #{pill.name} every #{pill.freq} days"
  end
end

# menu dialog
puts 'Did you take your pill today?'
response = gets.chomp

if response.empty? || positive(response)
  # log that I have taken such and such pills today onto the database
  pills_list.each do |pill|
    db.execute "INSERT INTO Log VALUES('#{pill.name}', #{pill.num}, '#{Date.today}')"
  end

  puts 'Good job!'
else
  puts 'Go take your pills for today.'
end

db.close