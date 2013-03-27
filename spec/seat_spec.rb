load "files.rb"

describe Seat do

  describe "#initialize" do
    it "makes the row human readable" do
      Seat.new(0,0).seat_number.should == "1A"
    end
  end

  describe "# <<" do
    it "adds a passenger" do
      passenger = Passenger.new
      seat = Seat.new(0,0)
      seat << passenger
      seat.passenger.should == passenger
    end
  end

  describe "#empty" do
    it "is empty" do
      Seat.new(0,0).empty?.should == true
    end

    it "is not empty" do
      passenger = Passenger.new
      seat = Seat.new(0,0)
      seat << passenger
      seat.empty?.should == false
    end
  end

  describe "#display" do
    let(:seat) { Seat.new(4, 3) }
    it "when full" do
      seat.stub(:empty?){ false }
      seat.display.should == "XX "
    end

    it "when empty" do
      seat.stub(:empty?){ true }
      seat.display.should == "5D "
    end
  end


end