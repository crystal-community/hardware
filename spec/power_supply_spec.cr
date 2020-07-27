require "spec"
require "../src/power_supply"
require "./power_supply/spec_helper"

describe Hardware::PowerSupply do
  power : Hardware::Battery

  begin
    power = Hardware::Battery.new
  rescue
    # If it did not found any battery device, then use the mock data in the
    # `spec/power_supply/mock/power_supply`
    Hardware::Battery.device_directory = Path.new({{ __DIR__ }})
      .join("power_supply", "mock", "power_supply")
    power = Hardware::Battery.new
  end

  it "checks the `entries_name` type" do
    Hardware::PowerSupply.entries_name.should be_a Array(String)
  end

  it "checks the `entries` type" do
    Hardware::PowerSupply.entries.should be_a Array(Hardware::PowerSupply)
  end

  it "checks the `type` type" do
    power.type.should be_a String
  end

  it "checks if the `type` is \"Battery\"" do
    power.type.should eq "Battery"
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
