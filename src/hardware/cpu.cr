# CPU related informations of your system.
#
# ```
# cpu = Hardware::CPU.new
# loop do
#   sleep 1
#   cpu.usage.to_i # => 17
# end
# ```
struct Hardware::CPU
  # Previous used CPU time
  getter previous_used : Int32 = 0
  # Previous idle CPU time
  getter previous_idle_wait : Int32 = 0
  # Returns a parsed `/proc/stat`
  getter stat : Array(Int32)

  # Creates a new `Hardware::CPU` based on the current memory state.
  def initialize
    @stat = update_stat
  end

  # Update the stats stored in `#stat`
  def update_stat : Array(Int32)
    @stat = File.read("/proc/stat").lines.first[5..-1].split(' ').map &.to_i
  end

  # Returns the CPU time used, which includes `idle` and `iowait`
  def idle_wait : Int32
    idle + iowait
  end

  # Returns the used CPU time, which includes `user`, `nice`, `system`, `irq`, `softirq` and `steal`
  def used : Int32
    user + nice + system + irq + softirq + steal
  end

  # Generate methods based on stat
  {% begin %}{% i = 0 %}
  {% for num in %w(user nice system idle iowait irq softirq steal guest guest_nice) %}
    # Returns the "{{num.id}}" field of `#stat`.
    def {{num.id}} : Int32
      @stat[{{i}}]
    end
    {% i = i + 1 %}
  {% end %}{% end %}

  # Returns the total CPU time, the sum of `#idle` and `#used`
  def total : Int32
    idle_wait + used
  end

  # Returns the CPU used in percentage based on `.previous_info`.
  def usage(update = true) : Float32
    # Update stats
    update_stat
    current_used, current_idle_wait = used, idle_wait

    # 100 * Usage / Total
    result = (current_used - @previous_used).to_f32 / (current_used + current_idle_wait - @previous_used - @previous_idle_wait) * 100

    @previous_used, @previous_idle_wait = current_used, current_idle_wait if update
    result
  end
end
