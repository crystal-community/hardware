# All informations related to the Processes running on your sytem, defined by Process IDentifiers.
#
# ```
# pid = Hardware::PID.new           # Default is Process.pid
# app = Hardware::PID.new "firefox" # Take the first matching PID
#
# loop do
#   sleep 1
#   pid.cpu_used      # => 1.5
#   app.cpu_used.to_i # => 4
# end
# ```
struct Hardware::PID
  # Pid number
  getter pid : Int32
  # Used to avoid duplicate operations when lots of `Hardware::PID` are created (like a top implementation)
  class_property cpu_total_current : Int32 = 0
  property cpu_total_previous : Int32 = 0
  property cpu_time_previous : Int32 = 0
  @cpu_time : Bool
  @cpu_total : Bool
  @stat : Array(String) = Array(String).new

  # Creates a new `Hardware::PID`
  # Set to false to avoid setting `#cpu_total_current` (useful if lots of `Hardware::PID` are used)
  def initialize(@pid : Int32 = Process.pid, @cpu_time = true, @cpu_total = true)
    @cpu_total_previous = @@cpu_total_current = CPU.new.info[:total] if @cpu_total
    @cpu_time_previous = self.cpu_time if @cpu_time
  end

  # Creates a new `Hardware::PID` by finding the `executable`'s pid.
  def initialize(executable : String, cpu_time = true, cpu_total = true)
    raise "no pid for '#{name}' exists" unless pid = Hardware::PID.get_pids(executable).first?
    initialize pid, cpu_time, cpu_total
  end

  private def read_proc(file : String) : String
    File.read "/proc/#{@pid}/" + file
  rescue ex
    raise "#{ex}\nVerify if a process that have a pid number of '#{pid}' exists"
  end

  # Yields a `Hardware::PID` for each PID present on the system.
  def self.all(cpu_time = false, cpu_total = false)
    Dir.each_child "/proc" do |pid_dir|
      if pid = pid_dir.to_i?
        yield Hardware::PID.new(pid: pid, cpu_time: cpu_time, cpu_total: cpu_total)
      end
    end
  end

  # Return all pids corresponding of a given `executable` name.
  def self.get_pids(executable : String)
    pids = Array(Int32).new
    all(cpu_time: false, cpu_total: false) do |pid|
      pid_name = pid.name
      pids << pid.pid if pid_name == executable
    end
    pids
  end

  # Returns a `String` representation of `/proc/``#pid``/cmdline`.
  def command : String
    cmdline.gsub '\0', ' '
  end

  # Returns `/proc/``#pid``/cmdline`.
  def cmdline : String
    read_proc "cmdline"
  end

  # Returns the CPU time without including ones from `children` processes.
  def cpu_time(children = false)
    # update stat
    stat

    # utime  - user
    # stime  - kernel
    # cutime - user, including time from children
    # cstime - kernel, including time from children
    if children
      utime + stime + cutime + cstime
    else
      utime + stime
    end
  end

  # Returns the CPU used in percentage.
  def cpu_used : Float32
    cpu_time_current = cpu_time
    @@cpu_total_current = CPU.new.info[:total] if @cpu_total

    # 100 * Usage / Total
    result = 100 * ((cpu_time_current - @cpu_time_previous.to_f32) / (@@cpu_total_current - @cpu_total_previous))

    @cpu_time_previous = cpu_time_current if @cpu_time
    @cpu_total_previous = @@cpu_total_current
    result
  end

  # Returns `/proc/``#pid``/exe` if readable.
  def exe : String?
    if File.readable? path = "/proc/#{@pid}/exe"
      File.real_path path
    end
  rescue
    nil
  end

  # Returns the actual memory used by the process.
  def memory
    # Assuming that PAGESIZE is 4096 kB
    statm.first * 4
  end

  # Returns the PID name based on `#exe` or `#cmdline`.
  def name
    File.basename (cmd = exe) ? cmd : command
  end

  # Returns a parsed `/proc/``#pid``/stat`.
  def stat
    @stat = read_proc("stat").split ' '
  end

  # Returns the "comm" field of `#stat`.
  def comm : String
    @stat[1]
  end

  # Returns the "state" field of `#stat`.
  def state : String
    @stat[2][1..-2]
  end

  # Generate methods based on stat
  {% begin %}{% i = 3 %}
  {% for num in %w(
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
    # Returns the "{{num.id}}" field of `#stat`.
    def {{num.id}} : Int32
      @stat[{{i}}].to_i
    end
    {% i = i + 1 %}
  {% end %}{% end %}

  # Returns a parsed `/proc/``#pid``/statm`.
  def statm : Array(Int32)
    read_proc("statm").split(' ').map &.to_i
  end

  # Returns a parsed `/proc/``#pid``/status`.
  def status : Hash(String, String)
    status_hash = Hash(String, String).new
    read_proc("status").each_line do |line|
      key, value = line.split ":\t"
      status_hash[key] = value
    end
    status_hash
  end
end
