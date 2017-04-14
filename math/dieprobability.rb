# die probability calculation, w/ the loops calculating nCr

largest = 0.0
max = 0
[*0..30].each do |n|
  p = 1
  [*0..n-1].each do |x|
    p *= 30 - x
    p /= 1 + x
  end
  pr = p * ((5 ** (30 - n)) / (6.0 ** 30))
  if pr > largest
    largest = pr
    max = n
  end
end
puts "max = #{max}"