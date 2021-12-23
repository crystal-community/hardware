# Parse stat initialized at `Hadware::PID#stat`
#
# ```
# pid_stat = Hardware::PID::Stat.new
# loop do
#   sleep 1
#   p pid_stat.cpu_usage! # => 1.5
# end
# ```
struct Hardware::PID::Stat
  getter data : Array(String) = Array(String).new
  getter pid : Int64
  @cpu : CPU?
  @cpu_time : Int64
  @cpu_time_children : Int64

  enum State
    Running
    Sleeping
    Wait
    Zombie
    Stopped
    TracingStop
    Paging
    Dead
    Interruptible

    def self.new(stat : String)
      case stat
      when "R"      then Running
      when "S"      then Sleeping
      when "D"      then Wait
      when "Z"      then Zombie
      when "T"      then Stopped
      when "t"      then TracingStop
      when "W"      then Paging
      when "x", "X" then Dead
      when "I"      then Interruptible
      else               raise Error.new "Invalid stat: #{stat}"
      end
    end
  end

  def initialize(@pid : Int64 = Process.pid, @cpu : CPU? = CPU.new)
    parse_stat_file
    @cpu_time = (utime + stime).to_i64
    @cpu_time_children = @cpu_time + (cutime + cstime).to_i64
  end

  {% begin %}
  {% stats = %w(
       ppid
       pgrp
       session
       tty_nr
       tpgid
       flags minflt
       cminflt
       majflt
       cmajflt
       utime
       stime
       cutime
       cstime
       priority
       nice
       numthreads
       itrealvalue
       starttime
       vsize
       rss) %}
  def parse_stat_file
    buffer = IO::Memory.new
    column_num = 0
    File.open "/proc/#{@pid}/stat", &.each_char do |char|
      case char
      when '('
        buffer << char if column_num != 1
      when ')'
        case column_num
        when 1
           @comm = buffer.to_s
          buffer.clear
          column_num += 1
        when 2 # skip if there is a parenthesis after the comm field
        else
          buffer << char
        end
      when ' ', '\n'
        next if buffer.empty?
        case column_num
        when 0 # skip pid field
        when 1 then next # comm field can have spaces
        when 2 then @state = State.new buffer.to_s
        {% i = 3 %}
        {% for stat in stats %}
        when {{i.id}} then @{{stat.id}} = buffer.to_s.to_i64
        {% i = i + 1 %}
        {% end %}
        end
        column_num += 1
        buffer.clear
      else
        buffer << char
      end
    end
  rescue ex
    raise Error.new "Failed to parse #{@pid}", ex
  end

  # Generate methods based on stat
  {% for stat in stats %}
  # Returns the "{{stat.id}}" stat field.
  getter {{stat.id}} : Int64 { parse_stat_file; @{{stat.id}} || raise Error.new "Field not parsed: '{{stat.id}}'" }
  {% end %}
  {% end %}

  getter comm : String { parse_stat_file; @comm || raise Error.new "Field not parsed: 'comm'" }
  getter state : State { parse_stat_file; @state || raise Error.new "Field not parsed: 'state'" }

  # Returns the CPU time with or without including ones from `children` processes.
  def cpu_time(children : Bool = false) : Int64
    # utime  - user
    # stime  - kernel
    # cutime - user, including time from children
    # cstime - kernel, including time from children
    @cpu_time = (utime + stime).to_i64

    @cpu_time_children = @cpu_time + (cutime + cstime).to_i64
    children ? @cpu_time_children : @cpu_time
  end

  # Returns the CPU used in percentage.
  # ```
  # pid_stat = Hardware::PID::Stat.new
  # loop do
  #   sleep 1
  #   p pid_stat.cpu_usage! # => 1.5
  # end
  # ```
  def cpu_usage!(children : Bool = false, current_cpu : CPU = CPU.new) : Float64
    cpu = @cpu || CPU.new
    previous_cpu_time = children ? @cpu_time_children : @cpu_time

    # 100 * Usage Time / Total Time
    parse_stat_file
    result = (cpu_time(children) - previous_cpu_time) / (current_cpu.total - cpu.total) * 100
    @cpu = current_cpu

    result.nan? ? 0_f64 : result
  end
end
