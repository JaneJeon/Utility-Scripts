# This program keeps track of pills you need to take, and keeps track of your history

# TODO: date checking, date alternating, checking previous records
# TODO: add 'not taken' when the date is missing

require 'date'

# first, check if file is empty
if !File.exist?('pills_history.txt')
  # if not, write a new file
  file = File.new("pills_history.txt", "w")
  menu_flag = "yes"

  # input the pill(s) that I need to take
  while (menu_flag.casecmp("yes") == 0 || menu_flag.casecmp("y") == 0)
    # TODO: ensure none of the entries are nil
    puts "What pill do you need to take?"
    pill = gets.chomp.split.first
    puts "How many? (number)"
    pill_num = gets.chomp.to_i
    puts "How often? (days)"
    pill_freq = gets.chomp.to_i
    # outputting line to file
    file.puts "Pills_to_take: #{pill} #{pill_num} #{pill_freq}"
    puts "Anything else?"
    menu_flag = gets.chomp
  end

  # don't forget to close file
  file.close
end

puts ""

pills_list = {}
# read through the file and collect pills info
File.open("pills_history.txt") do |lines|
  lines.each do |line|
    if line.split.first.eql? "Pills_to_take:"
      pill, pill_num, pill_freq = line.split[1..3]
      pill_num = pill_num.to_i
      pills_list[pill] = pill_num
    else
      break
    end
  end
end

if pills_list.count == 1
  puts "Pill to take:"
else
  puts "Pills to take:"
end

pills_list.each do |pill, pill_num|
  puts "#{pill_num} #{pill}"
end

# menu dialog
puts "Did you take your pill today?"
response = gets.chomp
if (response.casecmp("yes") == 0 || response.casecmp("y") == 0)
  # now that we know file is not empty, open file for editing
  file = File.new("pills_history.txt", "a")
  pills_log = "Taken: "
  pills_list.each do |pill, pill_num|
    pills_log += "#{pill} #{pill_num.to_s}, "
  end
  pills_log.chomp(",")
  pills_log += Date.today.to_s
  file.puts pills_log
  # don't forget to close at the end
  file.close
else
  puts "\nGo take your pills for today."
end