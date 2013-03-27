load "files.rb"

describe Aisle do

  let(:plane) { Airplane.new(4, 2) }
  let(:aisle) { Aisle.new(plane) }
  let(:passenger) { Passenger.new }

  describe "#initialize" do
    it "should have as many rows as the plane does" do
      aisle.row_count.should == 4
    end
  end

  describe "#seat_passenger" do
    it "seats passenger if they are ready" do
      passenger.stub(:ready?){true}
      passenger.stub(:assigned_seat){"1A"}
      aisle << passenger
      passenger.should_not_receive(:tick)
      aisle.seat_passenger(1)
      aisle.passenger_in_row(1).should be_nil
    end

    it "does not seat passenger if they are not ready" do
      aisle << passenger
      passenger.should_receive(:tick)
      aisle.seat_passenger(1)
    end
  end

  describe "<<" do

    it "adds to the front of the aisle" do
      aisle << passenger
      aisle.passenger_in_row(1).should == passenger
    end

    it "does not add if the front of the aisle is full" do
      aisle.stub(:full?){ true }
      aisle.passenger_in_row(1).should be_nil
    end
  end

  describe "#advance" do
    it "should advance if the next spot is empty" do
      passenger.assigned_seat = "3B"
      aisle.add_passenger_to(passenger, 2)
      aisle.advance(2)
      aisle.passenger_in_row(2).should be_nil
      aisle.passenger_in_row(3).should == passenger
    end

    it "should not advance if the next spot is full" do
      passenger.assigned_seat = "3B"
      aisle.add_passenger_to(passenger, 2)
      passenger2 = Passenger.new
      passenger2.assigned_seat = "3A"
      aisle.add_passenger_to(passenger2, 3)
      aisle.advance(2)
      aisle.passenger_in_row(2).should == passenger
    end
  end

  describe "#tick" do

    before do
      passenger.stub(:ready?){true}
    end

    it "should seat a passenger who is already in their row" do
      passenger.assigned_seat = "2B"
      aisle.add_passenger_to(passenger, 2)
      aisle.tick
      aisle.passenger_in_row(2).should be_nil
    end

    it "should advance a passenger who is not yet in their row" do
      passenger.assigned_seat = "3B"
      aisle.add_passenger_to(passenger, 2)
      aisle.tick
      aisle.passenger_in_row(2).should be_nil
      aisle.passenger_in_row(3).should == passenger
    end

    it "should advance from the back first" do
      aisle.should_receive(:has_passenger?).with(4).ordered
      aisle.should_receive(:has_passenger?).with(3).ordered
      aisle.should_receive(:has_passenger?).with(2).ordered
      aisle.should_receive(:has_passenger?).with(1).ordered
      aisle.tick
    end

    it "should properly seat someone in the last row" do
      passenger.assigned_seat = "4B"
      aisle.add_passenger_to(passenger, 4)
      aisle.tick
      aisle.passenger_in_row(4).should be_nil
      aisle.passenger_in_row(1).should be_nil
    end

    it "should properly seat someone in the first row" do
      passenger.assigned_seat = "1A"
      aisle.add_passenger_to(passenger, 1)
      aisle.tick
      aisle.passenger_in_row(1).should be_nil
      aisle.passenger_in_row(2).should be_nil
    end
  end

  describe "#empty?" do
    it "should be empty" do
      aisle.empty?.should == true
    end

    it "should be full" do
      aisle.add_passenger_to(Passenger.new, 1)
      aisle.empty?.should == false
    end
  end

  describe "#display" do
    it "should display nothing if empty" do
      aisle.display(1).should == "__ "
    end

    it "should display the seat assignment of the person" do
      passenger = Passenger.new
      passenger.assigned_seat = "3D"
      aisle << passenger
      aisle.display(1).should == "3D "
    end
  end

end