require "./spec_helper"

describe Hardware::CPU do
  it "parses '/proc/stat'" do
    Hardware::CPU.info.should be_a NamedTuple(used: Int32, idle: Int32, total: Int32)
  end

  it "checks the percentage used" do
    (0 <= Hardware::CPU.used <= 100).should be_true
  end
end
