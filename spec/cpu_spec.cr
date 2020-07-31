require "spec"
require "../src/cpu"

def assert_cpu_load(&)
  # Wait enough time to have measurable load
  cpu_usage = 0
  9.times do
    sleep 1
    cpu_usage = yield

    break if 0 < cpu_usage <= 100
  end
  cpu_usage.should be > 0
  cpu_usage.should be <= 100
end

describe Hardware::CPU do
  it "returns the usage compared to a previous CPU'" do
    cpu = Hardware::CPU.new
    assert_cpu_load { cpu.usage Hardware::CPU.new }
  end

  it "parses the last field (guest_nice)" do
    Hardware::CPU.new.guest_nice.should be_a Int64
  end

  it "returns the usage by mutating self" do
    cpu = Hardware::CPU.new
    assert_cpu_load { cpu.usage! }
  end
end
