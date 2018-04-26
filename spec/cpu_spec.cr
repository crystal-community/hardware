require "./spec_helper"

describe Hardware::CPU do
  it "parses '/proc/stat'" do
    Hardware::CPU.info.should be_a NamedTuple(used: Int32, idle: Int32, total: Int32)
  end

  it "checks the percentage used" do
    (0 <= Hardware::CPU.used <= 100).should be_true
  end

  it "checks the percentage in each_use" do
    Hardware::CPU.each_use do |cpu|
      (0 <= cpu <= 100).should be_true
      break
    end
  end
end
