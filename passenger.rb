class Passenger

  attr_accessor :assigned_seat
  attr_reader  :seating_time

  def initialize
    @seating_time = 5
  end

  def tick
    if @seating_time > 0
      @seating_time -= 1
    end
  end

  def ready?
    @seating_time == 0
  end

end