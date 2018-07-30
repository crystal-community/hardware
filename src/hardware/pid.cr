# All informations related to the Processes running on your sytem, defined by Process IDentifiers.
#
# ```
# pid = Hardware::PID.new           # Default is Process.pid
# app = Hardware::PID.new "firefox" # Take the first matching PID
#
# loop do
#   sleep 1
#   pid.cpu_usage      # => 1.5
#   app.cpu_usage.to_i # => 4
# end
# ```
struct Hardware::PID
  # Pid number
  getter pid : Int32
  # Used to avoid duplicate operations when lots of `Hardware::PID` are created (like a top implementation)
  class_property cpu_total_current : Int32 = 0
  # Previous `CPU.new.total`.
  property cpu_total_previous : Int32 = 0
  # Previous `#cpu_time`.
  property cpu_time_previous : Int32 = 0
  @cpu_total : Bool
  @stat = Stat.new Array(String).new

  # Creates a new `Hardware::PID`
  # Set to false to avoid setting `#cpu_total_current` (useful if lots of `Hardware::PID` are used)
  def initialize(@pid : Int32 = Process.pid, @cpu_total = true)
    raise "pid #{pid} doesn't exist" if !exists?
    @@cpu_total_current = CPU.new.total if @cpu_total
  end

  # Creates a new `Hardware::PID` by finding the `executable`'s pid.
  def initialize(executable : String, cpu_total = true)
    raise "no pid for '#{name}' exists" unless pid = Hardware::PID.get_pids(executable).first?
    initialize pid, cpu_total
  end

  private def read_proc(file : String) : String
    File.read "/proc/#{@pid}/#{file}"
  rescue ex
    raise "#{ex}\nVerify if a process that have a pid number of '#{pid}' exists"
  end

  # Yields a `Hardware::PID` for each PID present on the system.
  def self.all(cpu_total = false) : Nil
    Dir.each_child "/proc" do |pid_dir|
      if pid = pid_dir.to_i?
        yield Hardware::PID.new(pid: pid, cpu_total: cpu_total)
      end
    end
  end

  # Return all pids corresponding of a given `executable` name.
  def self.get_pids(executable : String) : Array(Int32)
    pids = Array(Int32).new
    all(cpu_total: false) do |pid|
      pids << pid.pid if pid.name == executable
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
  def cpu_time(children = false) : Int32
    # update stat
    stat

    # utime  - user
    # stime  - kernel
    # cutime - user, including time from children
    # cstime - kernel, including time from children
    if children
      @stat.utime + @stat.stime + @stat.cutime + @stat.cstime
    else
      @stat.utime + @stat.stime
    end
  end

  # Returns the CPU used in percentage.
  def cpu_usage : Float32
    cpu_time_current = cpu_time
    @@cpu_total_current = CPU.new.total if @cpu_total

    # 100 * Usage / Total
    result = (cpu_time_current - @cpu_time_previous).to_f32 / (@@cpu_total_current - @cpu_total_previous) * 100

    @cpu_time_previous = cpu_time_current

    @cpu_total_previous = @@cpu_total_current
    result
  end

  # Returns `/proc/``#pid``/exe` if readable.
  def exe : String
    File.real_path "/proc/#{@pid}/exe"
  end

  def exists? : Bool
    Dir.exists? "/proc/#{@pid}"
  end

  # Returns the actual memory used by the process.
  def memory : Int32
    # Assuming that PAGESIZE is 4096 kB
    statm.first * 4
  end

  # Returns the PID name based on `#exe` or `#cmdline`.
  def name : String
    File.basename exe
  rescue
    File.basename command
  end

  # Returns `Hardware::Net` for `#pid`
  def net : Net
    Net.new @pid
  end

  # Returns a parsed `/proc/``#pid``/stat`.
  def stat : Stat
    @stat = Stat.new read_proc("stat").split ' '
  end

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
