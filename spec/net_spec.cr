require "spec"
require "../src/net"

describe Hardware::Net do
  net = Hardware::Net.new

  it "checks some types" do
    net.in_octets.should be > 0_i64
    net.out_octets.should be > 0_i64
  end
end
