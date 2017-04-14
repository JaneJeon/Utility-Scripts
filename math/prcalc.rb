# die probability calculation... for HW

n = [10, 30, 50]
n.each do |n|
  sum = 0.0
  k = n * 7 / 10
  [*k..n].each do |k|
    p = 1
    [*0..k-1].each do |x|
      p *= n - x
      p /= 1 + x
    end
    sum += p
  end
  puts "at #{n}: #{sum / (2 ** n)}"
end