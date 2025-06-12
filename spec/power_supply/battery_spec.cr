require "spec"
require "../../src/power_supply/battery"
require "./spec_helper"

describe Hardware::Battery do
  battery : Hardware::Battery

  begin
    battery = Hardware::Battery.new
  rescue
    # If it did not found any battery device, then use the mock data in the
    # `spec/power_supply/mock/power_supply`
    Hardware::Battery.device_directory = Path.new({{ __DIR__ }}, "mock", "power_supply")
    battery = Hardware::Battery.new
  end

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
