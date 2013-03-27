load "files.rb"

describe Airplane do
  describe "#board_next_passenger" do
    let(:plane) {Airplane.new(3,2)}

    it "should add to the aisle" do
      passenger1 = Passenger.new
      plane.waiting_passengers = [passenger1]
      plane.board_next_passenger
      plane.aisle.passenger_in_row(1).should == passenger1
    end

    it "should be okay if there are no boarding passengers" do
      plane.waiting_passengers = []
      plane.board_next_passenger
      plane.aisle.passenger_in_row(1).should be_nil
    end

    it "should not lose a waiting passenger if the spot is full" do
      plane.aisle << Passenger.new

      passenger2 = Passenger.new
      plane.waiting_passengers = [passenger2]
      plane.board_next_passenger
      plane.waiting_passengers.should == [passenger2]
    end
  end

  describe "#tick" do
    it "should move passengers down the aisle" do
      passengers = 8.times.map{Passenger.new}

      first_to_board = passengers[0]
      first_to_board.assigned_seat = "2B"
      second_to_board = passengers[1]

      airplane = Airplane.new(8, 2)
      airplane.waiting_passengers = [first_to_board, second_to_board]

      airplane.tick
      airplane.aisle.passenger_in_row(1).should == first_to_board

      airplane.tick
      airplane.aisle.passenger_in_row(1).should == second_to_board
      airplane.aisle.passenger_in_row(2).should == first_to_board
    end

    describe "#seating" do
      let(:airplane) { Airplane.new(8,2) }
      let(:passenger) { Passenger.new }
      before do
        passenger.stub(:ready?){true}
      end

      it "should make a first row passenger take their seat" do
        passenger.assigned_seat = "1A"
        airplane.waiting_passengers = [passenger]
        airplane.tick
        airplane.tick
        airplane.passenger_in_seat("1A").should == passenger
      end

      it "should make a passengers take their seat" do
        passenger.assigned_seat = "5B"
        airplane.waiting_passengers = [passenger]
        6.times{ airplane.tick }
        airplane.passenger_in_seat("5B").should == passenger
      end
    end

  end

  describe "#full" do
    it "should know when it is full" do
      airplane = Airplane.new(2, 2)
      Seat.any_instance.stub(:empty?){ false }
      airplane.full?.should == true
    end

    it "should know when it is not full" do
      airplane = Airplane.new(2, 2)
      Seat.any_instance.stub(:empty?){ true }
      airplane.full?.should == false
    end
  end

  describe "#total_seats" do
    it "should know when same number of rows and columns" do
      Airplane.new(3,3).total_seats.should == 9
    end

    it "should know when different number of rows and columns" do
      Airplane.new(30,5).total_seats.should == 150
    end

    it "should be correct even if people have already loaded" do
      airplane = Airplane.new(3,3)
      airplane.stub(:full){ true }
      airplane.total_seats.should == 9
    end

  end

  describe "#seats_remaining" do
    it "should know how many seats are left" do
      airplane = Airplane.new(2,2)
      airplane.seats[0] << Passenger.new
      airplane.seats_remaining.should == 3
    end
  end

  context "#assign_seats" do
    let(:airplane) {Airplane.new(8,4)}

    it "when the plane is full" do
      passengers = 32.times.map{Passenger.new}
      airplane.waiting_passengers = passengers
      airplane.assign_seats
      passengers.select{|p| p.assigned_seat.nil? }.count.should == 0
    end

    it "when too few passengers" do
      passengers = 4.times.map{Passenger.new}
      airplane.waiting_passengers = passengers
      airplane.assign_seats
      passengers.select{|p| p.assigned_seat.nil? }.count.should == 0
    end

    it "should still work if there are too many passengers" do
      passengers = 40.times.map{Passenger.new}
      airplane.waiting_passengers = passengers
      airplane.assign_seats
      airplane.waiting_passengers.select{|p| p.assigned_seat.nil? }.count.should == 8
    end

    it "should not accidentally delete seats, oops" do
      passengers = 40.times.map{Passenger.new}
      airplane.waiting_passengers = passengers
      airplane.assign_seats
      airplane.seats.count.should == 32
    end

    it "should not board people with no seat assignment" do
      pending
    end

    context "#random" do
      before do
        passengers = 32.times.map{Passenger.new}
        airplane.waiting_passengers = passengers
      end

      it "should be random" do
        airplane.waiting_passengers.should_receive(:shuffle!)
        airplane.assign_seats(:random)
      end

      it "should be random, just in case" do
        #testing randomness, bwah ha ha
        airplane.assign_seats(:random)
        (  airplane.waiting_passengers[0].assigned_seat == "1A" &&
            airplane.waiting_passengers[1].assigned_seat == "1B" &&
            airplane.waiting_passengers[2].assigned_seat == "1C" &&
            airplane.waiting_passengers[3].assigned_seat == "1D"
        ).should == false
      end
    end

    context "#group" do
      before do
        passengers = 32.times.map{Passenger.new}
        airplane.waiting_passengers = passengers
        airplane.assign_seats(:group)
      end

      it "should load the back two rows first" do
        airplane.waiting_passengers[0..7].select{|p| p.assigned_seat.to_i >= 7}.count.should == 8
      end

      it "should load the front two rows last" do
        airplane.waiting_passengers[24..31].select{|p| p.assigned_seat.to_i <= 2}.count.should == 8
      end
    end
  end

  describe "#boarded?" do
    let(:airplane) {Airplane.new(2,2)}

    describe "fully boarded" do
      it "all seats are full" do
        airplane.stub(:full?){true}
        airplane.boarded?.should == true
      end

      it "aisle is empty & there are no waiting passengers" do
        airplane.boarded?.should == true
      end
    end

    describe "not fully boarded" do
      it "there are passengers in the aisle" do
        airplane.aisle = [Passenger.new]
        airplane.boarded?.should == false
      end

      it "there are passengers waiting to board" do
        airplane.waiting_passengers = [Passenger.new]
        airplane.boarded?.should == false
      end
    end
  end

  describe "#seat" do
    let(:airplane) {Airplane.new(2,2)}

    it "should seat a passenger" do
      passenger = Passenger.new
      passenger.assigned_seat = "1A"
      airplane.seat(passenger)
      airplane.passenger_in_seat("1A").should == passenger
    end

    it "should delay a passenger it blocks by 10 ticks" do
      passenger = Passenger.new
      passenger.assigned_seat = "1A"
      passenger2 = Passenger.new
      passenger2.assigned_seat = "1B"
      airplane.seat(passenger2)
      passenger.seating_time.should == 15
    end

    it "should not delay a passenger it blocks that is already seated" do

    end

    it "should not delay a passenger it doesn't block" do

    end

  end

  describe "#blocked_passengers" do
    let(:plane) {Airplane.new(2,2)}
    let(:passenger) { Passenger.new }

    it "should not find itself" do
      passenger.assigned_seat = "2B"
      passenger2 = Passenger.new
      passenger2.assigned_seat = "2A"
      plane.aisle << passenger
      plane.aisle << passenger2
      plane.passengers_blocked_by(passenger).should == [passenger2]
    end

    context "left side of plane" do
      before do
        passenger.assigned_seat = "1B"
      end

      it "should find blocked passengers in the aisle" do
        passenger2 = Passenger.new
        passenger2.assigned_seat = "1A"
        plane.aisle << passenger2
        plane.passengers_blocked_by(passenger).should == [passenger2]
      end

      it "should find blocked passengers waiting to board" do
        passenger2 = Passenger.new
        passenger2.assigned_seat = "1A"
        plane.waiting_passengers << passenger2
        plane.passengers_blocked_by(passenger).should == [passenger2]
      end

      it "should not find other passengers" do

      end
    end

  end
end