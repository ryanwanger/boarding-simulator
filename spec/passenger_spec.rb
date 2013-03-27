load "files.rb"

describe Passenger do

  describe "#ready?" do
    it "not ready when initialized" do
      Passenger.new.ready?.should == false
    end

    it "still not ready yet" do
      passenger = Passenger.new
      5.times{ passenger.tick}
      passenger.ready?.should == true
    end
  end

end