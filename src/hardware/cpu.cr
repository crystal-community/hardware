# CPU related informations of your system.
#
# ```
# cpu = Hardware::CPU.new
# loop do
#   sleep 1
#   cpu.used.to_i # => 17
# end
# ```
struct Hardware::CPU
  # Returns the previous used, idle and total CPU time. Used to store the previous CPU time informations to calculate the percentage in`.used`.
  class_property previous_info : NamedTuple(used: Int32, idle: Int32, total: Int32) = {used: 0, idle: 0, total: 0}
  @stat = Array(Int32).new

  # Creates a new `Hardware::CPU` based on the current memory state.
  def initialize
  end

  # Returns a parsed `/proc/stat`.
  def stat : Array(Int32)
    @stat = File.read("/proc/stat").lines.first[5..-1].split(' ').map &.to_i
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

  # Returns the current used, idle and total CPU time.
  def info : NamedTuple(used: Int32, idle: Int32, total: Int32)
    # update stat
    stat
    # Array: user nice system idle iowait irq softirq steal guest guest_nice
    {
      used:  used = user + nice + system + irq + softirq + steal,
      idle:  idle_cpu = idle + iowait,
      total: used + idle_cpu,
    }
  end

  # Returns the CPU used in percentage based on `.previous_info`.
  def used(update = true) : Float32
    current_info = info

    # 100 * Usage / Total
    result = (current_info[:used] - @@previous_info[:used]).to_f32 / (current_info[:total] - @@previous_info[:total]) * 100

    @@previous_info = current_info if update
    result
  end
end
