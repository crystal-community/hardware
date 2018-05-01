require "./spec_helper"

describe Hardware::CPU do
  cpu = Hardware::CPU.new
  it "parses '/proc/stat'" do
    cpu.info.should be_a NamedTuple(used: Int32, idle: Int32, total: Int32)
  end

  it "checks the percentage used" do
    Hardware::CPU.previous_info.should be_a NamedTuple(used: Int32, idle: Int32, total: Int32)
  end

  it "checks the percentage used" do
    sleep 0.1
    (0 <= cpu.used <= 100).should be_true
  end
end
