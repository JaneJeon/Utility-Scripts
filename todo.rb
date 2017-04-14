# a simple to-do app with hierarchy features
# @features: hierarchical tasks (creation, deletion, modification), date 
# reminder, checking off, move/reorganize (this can be done later), and 
# visualization of the hierarchy
# @author: Jane Jeon

# this was written from 30,000 ft above the ground - on a plane - where I did 
# not have access to the internet (and thus, StackOverflow) - so I had to make 
# do with what limited knowledge I had of Ruby and SQLite... so clearly, there 
# are lots of workaround 'tricks' for something that could probably done 
# directly (esp. type conversions).
# Also, I know it's really inefficient... but I don't plan on keeping track 
# of more than 10 tasks at a time anyway, so... yeah.

# please ignore any extraneous comments that aren't backed by a code snippet 
# - they are either tests or ramblings just for myself

require 'sqlite3'

# every task is part of some hierarchy. It keeps track of its sole parent task
# and all the sub-tasks. You can add notes to the task.
class Task
  # these three are required params. Children is empty by default.
  # Note that I'm not explicitly keeping track of parents, but instead only 
  # keeping track of the sub-tasks, which are stored wholly in children[]
  def initialize(task, note, date, done)
    @task = task
    @date = date
    @note = note
    @children = []
    @done = done
  end

  # can add multiple sub-tasks at once
  def add_children(*args)
    args.each { |arg| children << arg }
  end
  
  # can only remove one sub-task at a time
  def remove_child(arg)
    children.each_index { |i| children.delete_at(i) if children[i] == arg}
  end
  
  attr_accessor :task, :date, :note, :children, :done
end

# ------------------------------- start script ------------------------------- #

# database schema:
# id | task | note | date | done | [children_id]
db = SQLite3::Database.open 'todo.sqlite'

# I have no idea how to make 'date', 'boolean', and 'integer[]' types work
db.execute 'CREATE TABLE IF NOT EXISTS Tasks(id INTEGER, task TEXT, note 
            TEXT, date TEXT, done TEXT, parent INTEGER)'

# tasks is a hash of { id=>$the_actual_task }
tasks_list = {}
tasks_raw = db.execute 'SELECT * FROM Tasks'
to_visit = []

# first, stash in the top-level tasks
tasks_raw.each do |input|
  if input[5].zero?
    tasks_list[input[0]] = Task.new(input[1], input[2], input[3], 
                                    input[4].eql?('true'))
  else
    to_visit << input[0]
  end
end

# need to go through the list twice since we don't know if any given task's 
# parent task is already instantiated
until to_visit.empty?
  to_visit.each do |id|
    tasks_list.each do |k, v|
      # TODO
    end
  end
end

# printing the tasks in a hierarchical order
puts 'To-do list is empty!' if tasks_list.empty?

tasks_list.each do |task|
  # TODO: add in order
end

# db.execute "INSERT INTO Tasks VALUES(2, 'wash hands', 'description!', 
#             '#{Date.parse(Time.now.getlocal('-05:00').to_s.split.first)}', 
#             'false', '1 3 5')"

# input_array = db.execute "SELECT * FROM Tasks WHERE id=2"
# input = input_array[0]
# array=[0,1,2,3,4,5]
# array.each do |i|
#   puts "#{input[i]} is of type #{input[i].class}"
# end
# 
# conv = input[4].downcase.eql?'true'
# puts "date conversion: #{conv}, #{conv.class}"
# 
# conv2temp = input[5].split
# conv2 = []
# conv2temp.each do |i|
#   conv2 << i.to_i
# end
# puts "array conversion: #{conv2} of type #{conv2[0].class}"

# structure?
# [{ :task_name => 'clean up', :task_desc => '#{this} folder', :done => 
#    'false', :sub_task => [ { :task_name => 'do the laundry', :date => 
#                            #{tomorrow_date}, :done => false },
#                            { $another task }
#                          ] },
#  { :task_name => 'another one', :done => true, :date = 2016/02/03, 
#    :sub_task => [ { $task_1 }
#                 ] }
# ]
# TODO: fit a field of :id into every one of the above tasks

# restrictions:
# - a parent of 0, as read from the database, means the task has no parent
# - a parent task cannot have a due date earlier than the latest date of all of
#   its sub-tasks
# - marking the parent task 'done' means all of its sub-tasks are also done

db.close

# TODO: add priority