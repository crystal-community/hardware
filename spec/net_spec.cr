require "./spec_helper"

describe Hardware::Net do
  net = Hardware::Net.new

  it "checks some types" do
    net.in_octets.should be_a Int64
    net.out_octets.should be_a Int64
  end
end
