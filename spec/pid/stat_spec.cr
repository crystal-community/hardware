require "spec"
require "../../src/pid"

describe Hardware::PID::Stat do
  describe "cpu_time" do
    it "returns without children" do
      stat = Hardware::PID::Stat.new pid: 1
      stat.cpu_time.should be > 0
    end

    it "returns with children" do
      stat = Hardware::PID::Stat.new pid: 1
      stat.cpu_time(children: true).should be > 0
    end
  end

  it "checks cpu_usage percentage of all processes" do
    channel = Channel(Float64).new
    pids_count = 0
    Hardware::PID.each do |pid|
      begin
        spawn do
          stat = pid.stat
          sleep 4
          channel.send stat.cpu_usage!
        end
        pids_count += 1
      rescue ex : File::NotFoundError
      end
    end
    max_cpu_usage = 0
    pids_count.times do
      cpu_usage = channel.receive
      cpu_usage.should be >= 0
      cpu_usage.should be <= 100
      max_cpu_usage = cpu_usage if max_cpu_usage < cpu_usage
    end
    # At least one process in the system should have a cpu_usage superior to 0
    max_cpu_usage.should be > 0
  end
end
