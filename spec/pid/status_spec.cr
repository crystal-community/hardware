require "spec"
require "../../src/pid"

describe Hardware::PID::Status do
  status = Hardware::PID.new

  it "parses status name" do
    status.name.should eq "crystal-run-spec.tmp"
  end
end
