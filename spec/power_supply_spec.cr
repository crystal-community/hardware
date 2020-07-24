require "spec"
require "../src/power_supply"

battery_exists = false

begin
  Hardware::Battery.new_single
  battery_exists = true
rescue
end

if battery_exists
  describe Hardware::PowerSupply do
    power = Hardware::Battery.new_single

    it "checks the `type` type" do
      power.type.should be_a Hardware::PowerSupply::Type
    end

    it "checks the `serial_number` type" do
      power.serial_number.should be_a String
    end

    it "checks the `model_name` type" do
      power.model_name.should be_a String
    end

    it "checks the `manufacturer` type" do
      power.manufacturer.should be_a String
    end
  end
end
