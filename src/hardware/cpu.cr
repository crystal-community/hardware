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

  def self.used(sleep_time = 1)
    proc0 = info
    sleep sleep_time
    proc1 = info

    # 100 * Usage / Total
    (100 * ((proc1[:used] - proc0[:used]).to_f32 / (proc1[:total] - proc0[:total]))).round
  end
end
