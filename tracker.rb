# This program keeps track of pills you need to take, and keeps track of your history
# @author: Jane Jeon

# TODO: date checking, date alternating, checking previous records
# TODO: add 'not taken' when the date is missing

require 'date'
require 'ostruct'

FILE_PATH = 'pills_history.txt'

def positive(input)
  %w(yes y yep yeah).include? input.downcase
end

def update_prescription
  puts 'Update existing prescription:'
end

def add_prescription
  puts 'Add new prescription'
end

def delete_prescription
  puts 'Delete old prescription'
end

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
      break if pill != nil
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
File.open(FILE_PATH) do |lines|
  lines.each do |line|
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
end

if pills_list.count == 1
  puts 'Pill to take:'
else
  puts 'Pills to take:'
end

pills_list.each do |pill|
  if pill.freq == 1
    puts "#{pill.num} #{pill.name} pill every #{pill.freq} day"
  else
    puts "#{pill.num} #{pill.name} pill every #{pill.freq} days"
  end
end

# TODO: ask if user wants to update pills list
puts 'Any change in prescription?'
response = gets.chomp

if positive response || response.to_s.eql?('')
  puts 'Update/Add/Delete prescription: [u/a/d]'
  done = false

  update = %w(update u)
  add = %w(add a)
  delete = %w(delete d del)

  until done
    input = gets.chomp.split.first.to_s.downcase

    case input
      when *update
        update_prescription
      when *add
        add_prescription
      when *delete
        delete_prescription
      else
        puts 'u wot?'
    end

    puts 'done?'
    done_input = gets.chomp.to_s

    # include simple enter as yes, as the person might want to simply escape
    done = true if positive done_input || done_input.eql?('')
  end
end

# menu dialog
puts 'Did you take your pill today?'
response = gets.chomp

if positive response || response.to_s.eql?('')
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