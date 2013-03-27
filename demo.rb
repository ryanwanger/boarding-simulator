load 'files.rb'

plane = Airplane.new(8,4, 32.times.map{Passenger.new})
plane.assign_seats(:random)

ticks = 1

while plane.boarded? == false
  p "Tick: #{ticks}"
  plane.display
  plane.tick
  ticks += 1
end

p "Tick: #{ticks}"
plane.display
