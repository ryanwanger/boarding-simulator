class Aisle

  attr_accessor :rows

  def initialize(airplane, window = nil)
    @rows = Array.new airplane.rows
    @airplane = airplane
    @window = window
  end

  def tick
    row_number = @rows.count

    while row_number > 0
      if has_passenger?(row_number) && reached_seat?(row_number)
        seat_passenger row_number
      else
        advance row_number
      end
      row_number -= 1
    end
  end

  def seat_passenger(row_number)
    passenger = @rows[row_number-1]
    if passenger.ready?
      @rows[row_number-1] = nil
      @airplane.seat(passenger)
    else
      passenger.tick
    end
  end

  def advance(row_number)
    if @rows[row_number].nil?
      @rows[row_number] = @rows[row_number-1]
      @rows[row_number-1] = nil
    end
  end

  def has_passenger?(row_number)
    !@rows[row_number-1].nil?
  end

  def reached_seat?(row_number)
    @rows[row_number-1].assigned_seat.to_i == row_number
  end

  def passenger_in_row(row_number)
    @rows[row_number-1]
  end

  def has_space?
    @rows[0].nil?
  end

  def <<(val)
    @rows[0] = val if has_space?
  end

  def add_passenger_to(passenger, row_number)
    @rows[row_number-1] = passenger
  end

  def row_count
    @rows.count
  end

  def empty?
    @rows.compact.count == 0
  end

  def display(row_number)
    spot = @rows[row_number-1]
    if spot == nil
      "__ "
    else
      "#{spot.assigned_seat} "
    end
  end

  def draw(row_number, position, offset)
    width = 64
    height = 64

    @x = position * width + offset
    @y = row_number * height
    Gosu::Image.new(@window, "images/carpet.gif", false).draw(@x, @y, 1)
    if has_passenger?(row_number)
      passenger = passenger_in_row(row_number)
      @font = Gosu::Font.new(@window, Gosu::default_font_name, 16)
      @font.draw(passenger.assigned_seat, @x+16, @y+25, 3, 1.0, 1.0, 0xffff0000)


      Gosu::Image.new(@window, "images/person-icon.gif", false).draw(@x, @y, 2)

    end
  end
end