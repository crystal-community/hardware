module Hardware::CPU
  def self.info
    cpu = File.read("/proc/stat").lines.first[5..-1].split(' ').map &.to_i
    # Array: user nice system idle iowait irq softirq steal guest guest_nice
    {
      used:  used = cpu[0] + cpu[1] + cpu[2] + cpu[5] + cpu[6] + cpu[7],
      idle:  idle = cpu[3] + cpu[4],
      total: used + idle,
    }
  end

  def self.each_use(sleep_time = 1)
    proc_last = info
    loop do
      sleep sleep_time
      proc_now = info

      # 100 * Usage / Total
      yield (proc_now[:used] - proc_last[:used]).to_f32 / (proc_now[:total] - proc_last[:total]) * 100
      proc_last = proc_now
    end
  end

  def self.used(sleep_time = 1)
    each_use(sleep_time) { |cpu| return cpu }
  end
end
