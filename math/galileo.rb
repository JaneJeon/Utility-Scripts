# number of triples that sum up to 9 or 10
puts 'How many simulations?'
total = gets.chomp.to_i
sum9 = 0
sum10 = 0
total.times do
  # simulating roll of 3 die
  die3 = 3 + rand(6) + rand(6) + rand(6)
  if die3 == 9
    sum9 += 1
  elsif die3 == 10
    sum10 += 1
  end
end
puts "probability of 9 is #{sum9.to_f / total}, and for 10 it's 
      #{sum10.to_f / total}"