module Hardware::CPU
  def self.info
    cpu = File.read("/proc/stat").lines.first[5..-1].split(' ').map &.to_i
    {
      used: cpu[0] + cpu[1] + cpu[2],
      idle:  cpu[3],
      total: cpu[0] + cpu[1] + cpu[2] + cpu[3],
    }
  end

  def self.used(sleep_time = 1)
    proc0 = info
    sleep sleep_time
    proc1 = info

    # 100 * Usage / Total
    100 * ((proc1[:used] - proc0[:used]).to_f32 / (proc1[:total] - proc0[:total]).to_f32)
  end
end
