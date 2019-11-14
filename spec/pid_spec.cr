require "spec"
require "../src/pid"

describe Hardware::PID do
  describe "class methods" do
    it "tests .get_pids of the current process" do
      Hardware::PID.get_pids "crystal-run-spec.tmp", &.should eq Process.pid
    end
  end

  describe "instance methods" do
    it "creates a Hardware::PID based on a name" do
      Hardware::PID.new("crystal-run-spec.tmp").number.should eq Process.pid
    end

    pid = Hardware::PID.new

    it "creates a non existant PID" do
      expect_raises Exception do
        Hardware::PID.new(number: 0)
      end
    end

    it "parses exe" do
      File.basename(pid.exe).should eq "crystal-run-spec.tmp"
    end

    it "parses command" do
      File.basename(pid.command).should eq "crystal-run-spec.tmp "
    end

    it "returns memory usage" { pid.memory.should be > 1 }
  end
end
