require "./spec_helper"

describe Hardware::PID do
  describe "class methods" do
    it "tests .all " do
      Hardware::PID.all { |pid| pid.should be_a Hardware::PID }
    end

    it "tests .get_pids of the current process" do
      Hardware::PID.get_pids("crystal-run-spec.tmp").should eq [Process.pid]
    end

    it "cpu_total_current equal to cpu_total_previous" do
      Hardware::PID.cpu_total_current.should eq 0
    end
  end

  describe "instance methods" do
    it "creates a Hardware::PID based on a name" do
      Hardware::PID.new("crystal-run-spec.tmp", cpu_time: false, cpu_total: false).pid.should eq Process.pid
    end

    pid = Hardware::PID.new

    it "creates a non existant PID" do
      expect_raises Exception do
        Hardware::PID.new(pid: 0)
      end
    end

    it "parses exe" do
      File.basename(pid.exe.not_nil!).should eq "crystal-run-spec.tmp"
    end

    it "parses command" do
      File.basename(pid.command).should eq "crystal-run-spec.tmp "
    end

    describe "tests CPU related methods for" do
      describe "cpu_time" do
        pid1 = Hardware::PID.new(pid: 1)
        it "without children" do
          (1 < pid1.cpu_time).should be_true
        end

        it "with children" do
          (1 < pid1.cpu_time(children: true)).should be_true
        end
      end

      describe "cpu_used with updates" do
        pid1 = Hardware::PID.new(pid: 1)

        it "percentage" do
          # Simulate CPU use if no activity
          pid1.cpu_time_previous = pid1.cpu_time - 9
          sleep 0.1
          (1 < pid1.cpu_used <= 100).should be_true
        end

        it "cpu_total_previous equal to cpu_total_current" do
          pid1.cpu_total_previous.should eq Hardware::PID.cpu_total_current
        end
      end
      describe "cpu_used with no updates" do
        Hardware::PID.cpu_total_current = -1
        pid1 = Hardware::PID.new(pid: 1, cpu_time: false, cpu_total: false)
        pid1.cpu_time_previous = -1

        it "type" do
          pid1.cpu_used.should be_a Float32
        end

        it "cpu_time_previous not updated" do
          pid1.cpu_time_previous.should eq -1
        end

        it "cpu_total_current not updated" do
          Hardware::PID.cpu_total_current.should eq -1
        end

        it "cpu_total_previous not updated" do
          pid1.cpu_total_previous.should eq -1
        end
      end
    end

    it "returns memory used" { (1 < pid.memory).should be_true }

    it "parses name" { pid.name.should eq "crystal-run-spec.tmp" }

    it "parses name" { pid.net.should be_a Hardware::Net }

    it "parses stat" { pid.stat.should be_a Hardware::PID::Stat }

    it "parses statm" { pid.statm.should be_a Array(Int32) }

    it "parses status" { pid.status.should be_a Hash(String, String) }
  end
end
