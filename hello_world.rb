require 'gosu'
load 'files.rb'

class MyWindow < Gosu::Window
  attr_accessor :planes

  def initialize(plane_specs)
    @x, @y = 0, 0
    super(1530, 1000, false)
    self.caption = 'Hello World!'

    @planes = []
    plane_specs.map.each do |p|
      plane = Airplane.new(p[0], p[1], p[2] ? p[2] : [], self, p[3])
      plane.assign_seats(p[3])
      @planes << plane
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end

  def update
    @planes.each do |plane|
      unless plane.boarded?
        plane.tick
        #sleep(0.02)
      end
    end
  end

  def draw
    @planes.each_with_index{|p, index| p.draw(index*500)}
  end
end

window = MyWindow.new([[8,6, 48.times.map{Passenger.new}, :random], [8,6, 48.times.map{Passenger.new}, :group]])
window.show