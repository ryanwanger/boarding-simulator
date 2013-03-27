class Seat
  attr_accessor :passenger
  attr_accessor :row
  attr_accessor :column
  attr_accessor :letter

  def initialize(row, column, window = nil)
    @passenger = nil
    @row = row + 1
    @column = column
    @letter = Seat.get_letter(column)
    @window = window
  end

  def seat_number
    "#{@row}#{@letter}"
  end

  def self.get_letter(column)
    case column
      when 0
        "A"
      when 1
        "B"
      when 2
        "C"
      when 3
        "D"
      when 4
        "E"
      when 5
        "F"
    end
  end

  def empty?
    @passenger == nil
  end

  def full?
    !empty?
  end

  def <<(val)
    @passenger = val
  end

  def display
    if empty?
      "#{seat_number} "
    else
      "XX "
    end
  end

  def draw(position, offset)
    width = 64
    height = 64
    @font = Gosu::Font.new(@window, Gosu::default_font_name, 36)

    @x = position * width + offset
    @y = self.row * height

    @window.draw_quad(@x, @y, 0xffffffff, @x + width, @y, 0xffffffff, @x + width, @y + height, 0xffffffff, @x, @y + height, 0xffffffff, 0)

    if empty?
      @font.draw(seat_number, @x + 15, @y + 15, 3, 1.0, 1.0, 0xffff0000)
    else
      Gosu::Image.new(@window, "images/person-icon.gif", false).draw(@x, @y, 2)
    end

  end
end