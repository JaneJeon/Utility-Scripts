# This program keeps track of pills you need to take, and keeps track of your history
# @author: Jane Jeon

# TODO: check previous records and date frequency
# TODO: add 'not taken' when the date is missing
# TODO: add support for individual pills

require 'date'
require 'ostruct'

FILE_PATH = 'pills_history.txt'

def positive(input)
  %w(yes y yep yeah).include? input.downcase
end

# TODO: test and sanitize inputs
def update_prescription(pills_list)
  if pills_list.count == 1
    # assume that user wants to change the only pill
    update_prescription_helper pills_list[0]
  else
    done = false
    until done
      input = ''

      loop do
        puts 'Which pill to update?'
        input = gets.chomp.split.first
        break unless input.empty?
      end

      pill = pills_list.select {|p| p.name.eql?(input)}
      update_prescription_helper pill unless pill.nil?

      puts 'done?'
      done_input = gets.chomp
      done = true if done_input.empty? || positive(done_input)
    end
  end
end

def update_prescription_helper(pill)
  valid_input = true
  puts 'Update name/amount/frequency? [n/a/f]'

  name = %w(name n pill)
  amount = %w(count a num number)
  frequency = %w(frequency f freq day days)

  response = gets.chomp.split.first.downcase
  case response
    when *name
      input = ''

      loop do
        puts 'What\'s the new name?'
        input = gets.chomp.split.first
        break unless input.empty?
      end

      replace(pill.name, 1, input.downcase)
    when *amount
      input = 0

      loop do
        puts "How many? (currently #{pill.num})"
        input = gets.chomp.to_i
        break if input != 0
      end

      replace(pill.num, 2, input)
    when *frequency
      input = 0

      loop do
        if pill.freq == 1
          puts 'How often? (currently every 1 day)'
        else
          puts "How often? (currently every #{pill.freq} days"
        end
        input = gets.chomp.to_i
        break if input != 0
      end

      replace(pill.freq, 2, input)
    else
      puts 'u wot?'
      valid_input = false
  end

  puts "Updated entry for #{pill.name}!" if valid_input
end

def replace(pill, breakpoint, new_val)
  to_replace = []

  File.open(FILE_PATH).each do |line|
    line_split = line.split

    if line_split.first.eql?('Pills_to_take:') && line_split[1].eql?(pill)
      line_split[breakpoint] = new_val

      line_new = ''
      line_split.each do |word|
        line_new << word + ' '
      end

      to_replace << line.chomp
      to_replace << line_new.chomp

      break
    end
  end

  # basically rewrite file with the modified line
  file = File.read(FILE_PATH)

  unless to_replace.empty?
    content = file.gsub(to_replace[0], to_replace[1])
    File.open(FILE_PATH, 'w') { |f| f << content}
  end
end

# TODO: flesh these out
def add_prescription(pill)
  puts 'Add new prescription'
end

def delete_prescription(pill)
  puts 'Delete old prescription'
end

# -------------- end of methods -------------- #

# -------------- begin program --------------- #

# first, check if file is empty
unless File.exist?(FILE_PATH)
  menu_flag = 'yes'
  # create new file if file doesn't exist
  file = File.new(FILE_PATH, 'w')

  # input the pill(s) that I need to take
  while positive menu_flag
    # initialize variables here so they can be accessed outside loops
    pill = '', pill_num = pill_freq = 0

    # loops to ensure that user is inputting something
    loop do
      puts 'What pill do you need to take?'
      pill = gets.chomp.split.first
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

    # outputting line to file only when all 3 parameters are set
    file.puts "Pills_to_take: #{pill} #{pill_num} #{pill_freq}"

    puts 'Anything else?'
    menu_flag = gets.chomp
  end

  # don't forget to close file
  file.close
end

puts ''
pills_list = []

# read through the file and collect pills info
File.open(FILE_PATH).each do |line|
  if line.split.first.eql? 'Pills_to_take:'
    pill_name, pill_num, pill_freq = line.split[1..3]

    pill = OpenStruct.new
    pill.name = pill_name
    pill.num = pill_num.to_i
    pill.freq = pill_freq.to_i

    pills_list << pill
  else
    break
  end
end

if pills_list.count == 1
  puts 'Pill to take:'
else
  puts 'Pills to take:'
end

pills_list.each do |pill|
  if pill.freq == 1
    puts "#{pill.num} #{pill.name} pill every day"
  else
    puts "#{pill.num} #{pill.name} pill every #{pill.freq} days"
  end
end

puts 'Any change in prescription?'
response = gets.chomp

if positive response
  puts 'Update/Add/Delete prescription: [u/a/d]'
  done = false

  update = %w(update u)
  add = %w(add a)
  delete = %w(delete d del)

  until done
    input = gets.chomp.split.first.downcase

    case input
      when *update
        update_prescription (pills_list)
      when *add
        add_prescription pills_list
      when *delete
        delete_prescription pills_list
      else
        puts 'u wot?'
    end

    puts 'done?'
    done_input = gets.chomp
    done = true if done_input.empty? || positive(done_input)
  end
end

# menu dialog
puts 'Did you take your pill today?'
response = gets.chomp

if response.empty? || positive(response)
  # now that we know file is not empty, open file for editing
  file = File.new(FILE_PATH, 'a')

  pills_log = 'Taken: '
  pills_list.each do |pill|
    pills_log += "#{pill.num.to_s} #{pill.name}, "
  end
  pills_log.chomp(',')
  pills_log += Date.today.to_s

  # write to file then close it
  file.puts pills_log
  file.close

  puts 'Good job!'
else
  puts 'Go take your pills for today.'
end