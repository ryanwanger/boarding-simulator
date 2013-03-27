class Airplane

  attr_accessor :seats
  attr_accessor :aisle
  attr_accessor :rows
  attr_accessor :waiting_passengers
  attr_accessor :ticks

  def initialize(row_count, column_count, passengers = [], window = nil, boarding_type)
    @rows = row_count
    @columns = column_count
    @ticks = 0

    @seats = []
    @rows.times do |row|
      @columns.times do |column|
        @seats << Seat.new(row, column, window)
      end
    end

    @aisle = Aisle.new(self, window)
    @waiting_passengers = passengers
    @window = window
    @boarding_type = boarding_type
  end

  def tick
    @aisle.tick
    @ticks += 1
    board_next_passenger
  end

  def boarded?
    full? || (@aisle.empty? && no_waiting_passengers?)
  end

  def passenger_in_seat(seat_number)
    @seats.detect{ |it| it.seat_number == seat_number }.passenger
  end

  def assign_seats(method = :random)

    seats = @seats.dup

    @waiting_passengers.each do |passenger|
      passenger.assigned_seat = seats.shift.seat_number if seats.any?
    end

    case method

      when :random
        @waiting_passengers.shuffle!

      when :group
        number_of_groups = 4
        temp_passengers = []
        passengers_per_group = @waiting_passengers.count / number_of_groups

        number_of_groups.times do
          group = []
          passengers_per_group.times{group << @waiting_passengers.pop}
          temp_passengers += group.shuffle
        end

        @waiting_passengers = temp_passengers.flatten
    end

  end

  def seat(passenger)
    letter = passenger.assigned_seat.slice(-1)
    row = passenger.assigned_seat.to_i
    seat = @seats.detect { |s| s.row == row && s.letter == letter }
    seat << passenger

    #passengers_blocked_by(passenger).each{|p| p.seating_time += 10}
  end

  # factor in the aisle
  def passengers_blocked_by(passenger)
    passengers = []
    passengers = @aisle.rows.compact.select{|p| p.assigned_seat.to_i == passenger.assigned_seat.to_i}
    passengers += @waiting_passengers.select{|p| p.assigned_seat.to_i == passenger.assigned_seat.to_i}
    passengers = passengers.select{|p| p != passenger}
    passengers
  end

  def board_next_passenger
    if @aisle.has_space? && @waiting_passengers.any?
      @aisle << @waiting_passengers.shift
    end
  end

  def full?
    @seats.each { |seat| return false if seat.empty? }
    true
  end

  def total_seats
    @seats.count
  end

  def seats_remaining
    @seats.select{ |seat| seat.empty? }.count
  end

  def display
    @seats.each_with_index do |seat, index|
      print "\n" if new_row?(index, seat)
      print @aisle.display((index / @columns) + 1) if aisle?(index)
      print seat.display
    end

    print "\n\n\n"
    true
  end

  def draw(offset)
    position = 0
    @seats.each_with_index do |seat, index|
      if aisle?(index)
        aisle.draw(seat.row, position, offset)
        position += 1
      end
      position = 0 if new_row?(index, seat)

      seat.draw(position, offset)
      position += 1
    end

    @font = Gosu::Font.new(@window, Gosu::default_font_name, 40)
    @font.draw("Time: #{@ticks}", 0+offset, 0, 3, 1.0, 1.0, 0xffff0000)

    progress_length = ((total_seats - seats_remaining)/total_seats.to_f) * 450

    @window.draw_quad(offset, 40, 0xff00ffff,
                      offset + progress_length, 40, 0xff00ffff,
                      offset + progress_length, 50, 0xff00ffff,
                      offset, 50, 0xff00ffff, 0)

    @font.draw("#{@boarding_type.capitalize} boarding", 0+offset, 575, 3, 1.0, 1.0, 0xffff0000)


    @font.draw("Boarded", 305+offset, 0, 3, 1.0, 1.0, 0xffff0000) if boarded?

  end

  private

  def new_row?(seat_index, seat)
    seat_index != 0 && seat.row != @seats[seat_index-1].row
  end

  def aisle?(seat_index)
    seat_index % @columns == @columns / 2
  end

  def no_waiting_passengers?
    waiting_passengers.compact.count == 0
  end

end