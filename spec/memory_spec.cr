require "./spec_helper"

describe Hardware::Memory do
  memory = Hardware::Memory.new

  it "parses '/proc/meminfo'" do
    memory.meminfo.should be_a Hash(String, Int64)
  end

  it "checks the `total` type" do
    memory.total.should be_a Int32
  end

  it "checks the `available` type" do
    memory.available.should be_a Int32
  end

  it "checks the `used` type" do
    memory.used.should be_a Int32
  end

  it "checks the percentage available" do
    (1 < memory.percent(used: false) <= 100).should be_true
  end

  it "checks the percentage used" do
    (1 < memory.percent(used: true) <= 100).should be_true
  end
end
