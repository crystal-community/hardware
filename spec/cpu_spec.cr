require "./spec_helper"

describe Hardware::CPU do
  cpu = Hardware::CPU.new
  it "parses '/proc/stat'" do
    cpu.stat.should be_a Array(Int32)
  end

  it "checks the percentage used" do
    cpu.previous_used.should be_a Int32
    cpu.previous_idle_wait.should be_a Int32
  end

  it "checks the percentage used" do
    sleep 0.1
    usage = cpu.usage
    usage.should be >= 0
    usage.should be <= 100
  end
end
