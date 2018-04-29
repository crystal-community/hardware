struct Hardware::CPU
  class_property previous_info : NamedTuple(used: Int32, idle: Int32, total: Int32) = CPU.info

  def initialize
  end

  def self.info
    cpu = File.read("/proc/stat").lines.first[5..-1].split(' ').map &.to_i
    # Array: user nice system idle iowait irq softirq steal guest guest_nice
    {
      used:  used = cpu[0] + cpu[1] + cpu[2] + cpu[5] + cpu[6] + cpu[7],
      idle:  idle = cpu[3] + cpu[4],
      total: used + idle,
    }
  end

  def used(update = true)
    current_info = CPU.info

    # 100 * Usage / Total
    result = (current_info[:used] - @@previous_info[:used]).to_f32 / (current_info[:total] - @@previous_info[:total]) * 100

    @@previous_info = current_info if update
    result
  end
end
