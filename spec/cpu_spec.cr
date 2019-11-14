require "spec"
require "../src/cpu"

describe Hardware::CPU do
  it "returns the usage compared to a previous CPU'" do
    cpu = Hardware::CPU.new
    sleep 6
    cpu_usage = cpu.usage Hardware::CPU.new
    cpu_usage.should be > 0
    cpu_usage.should be <= 100
  end

  it "parses the last field (guest_nice)" do
    Hardware::CPU.new.guest_nice.should be_a Int32
  end

  it "returns the usage by mutating self" do
    cpu = Hardware::CPU.new
    sleep 6
    cpu_usage = cpu.usage!
    cpu_usage.should be > 0
    cpu_usage.should be <= 100
  end
end
