# CPU related informations of your system.
#
# ```
# cpu = Hardware::CPU.new
# loop do
#   sleep 1
#   p cpu.usage!.to_i # => 17
# end
# ```
struct Hardware::CPU
  # CPU number. `nil` means the whole cores in total.
  getter number : Int32?

  # Creates a new CPU stat to monitor the given core.
  #
  # Must be lower than `System.cpu_count`, or `nil` for the whole cores in total.
  def initialize(number : Int32? = nil, parse_stats : Bool = true)
    if @number = number
      raise "CPU number must be superior or equal to 0, and inferior to #{System.cpu_count}" unless 0 <= number < System.cpu_count
    end
    parse_stat_file if parse_stats
  end

  {% begin %}
    {% stats = %w(user nice system idle iowait irq softirq steal guest guest_nice) %}
    {% for stat in stats %}
    # Returns the {{stat}} stat field.
    getter {{stat.id}} : Int32 { parse_stat_file; @{{stat.id}} || raise "Field not parsed: '{{stat.id}}'" }
    {% end %}
    
    private def parse_stat_line(column_num : Int32, buffer : IO)
      case column_num
      {% i = 1 %}
      {% for stat in stats %}
      when {{i}} then @{{stat.id}} = buffer.to_s.to_i
      {% i = i + 1 %}
      {% end %}
      end
      buffer.clear
    end
  {% end %}

  private def parse_stat_file
    # /proc/stat content:
    # cpu
    # cpu0
    # cpu1
    # ...
    line_num = -1
    column_num = 0
    buffer = IO::Memory.new
    File.open "/proc/stat", &.each_char do |char|
      if !@number && line_num == -1 || line_num == @number
        if (char == ' ' || char == '\n') && !buffer.empty?
          parse_stat_line column_num, buffer

          buffer.clear
          column_num += 1
        else
          buffer << char
        end
      end
      if char == '\n'
        line_num += 1
        break if line_num < System.cpu_count
        column_num = 0
      end
    end
  end

  # Sum of `user`, `nice`, `system`, `irq`, `softirq` and `steal`.
  getter used : Int32 { user + nice + system + irq + softirq + steal }

  # Sum of `idle` and `iowait`.
  getter idle_total : Int32 { idle + iowait }

  # Sum of `used` and `idle_total`
  getter total : Int32 { used + idle_total }

  # Returns each CPU usage in percentage based on the previous `CPU`.
  def usage(previous_cpu : CPU = self) : Float64
    # Usage Time / Total Time * 100
    (used - previous_cpu.used) / (total - previous_cpu.total) * 100
  end

  # Like `#usage`, but mutates the instance.
  #
  # ```
  # cpu = Hardware::CPU.new
  # loop do
  #   sleep 1
  #   p cpu.usage!.to_i # => 17
  # end
  # ```
  def usage! : Float64
    # 100 * Usage Time / Total Time
    @user || raise "Stat file not previously parsed"
    previous_cpu = self
    @used = @idle_total = @total = nil
    parse_stat_file
    usage previous_cpu
  end
end
