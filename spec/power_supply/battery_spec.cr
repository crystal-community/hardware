require "spec"
require "../../src/power_supply/battery"

battery_exists = false

begin
  Hardware::Battery.new
  battery_exists = true
rescue
end

if battery_exists
  describe Hardware::Battery do
    battery = Hardware::Battery.new

    it "checks the `type` type" do
      battery.type.should be_a String
    end

    it "checks the `capacity` type" do
      battery.capacity.should be_a UInt8
    end

    it "checks the `status` type" do
      battery.status.should be_a Hardware::Battery::Status
    end
  end
end
