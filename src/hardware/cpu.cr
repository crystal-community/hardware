struct Hardware::CPU
  class_property previous_info : NamedTuple(used: Int32, idle: Int32, total: Int32) = {used: 0, idle: 0, total: 0}
  @stat = Array(Int32).new

  def initialize
  end

  def stat
    @stat = File.read("/proc/stat").lines.first[5..-1].split(' ').map &.to_i
  end

  # Generate methods based on stat
  {% begin %}{% i = 0 %}
  {% for num in %w(user nice system idle iowait irq softirq steal guest guest_nice) %}
    def {{num.id}}
      @stat[{{i}}]
    end
    {% i = i + 1 %}
  {% end %}{% end %}

  def info
    # update stat
    stat
    # Array: user nice system idle iowait irq softirq steal guest guest_nice
    {
      used:  used = user + nice + system + irq + softirq + steal,
      idle:  idle_cpu = idle + iowait,
      total: used + idle_cpu,
    }
  end

  def used(update = true)
    current_info = info

    # 100 * Usage / Total
    result = (current_info[:used] - @@previous_info[:used]).to_f32 / (current_info[:total] - @@previous_info[:total]) * 100

    @@previous_info = current_info if update
    result
  end
end
