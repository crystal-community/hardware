struct Hardware::PID
  getter pid : Int32
  @status = Hash(String, String).new
  # Used to avoid duplicate operations when lots of Hardware::PID are created (like a top implementation)
  class_property cpu_total_current = 0
  property cpu_total_previous = 0
  property cpu_time_previous = 0
  @cpu_time : Bool
  @cpu_total : Bool

  def initialize(@pid : Int32 = Process.pid, @cpu_time = true, @cpu_total = true)
    @cpu_total_previous = @@cpu_total_current = CPU.info[:total] if @cpu_total
    @cpu_time_previous = self.cpu_time if @cpu_time
  end

  def initialize(executable : String, cpu_time = true, cpu_total = true)
    raise "no pid for '#{name}' exists" unless pid = Hardware::PID.get_pids(executable).first?
    initialize pid, cpu_time, cpu_total
  end

  private def read_proc(file)
    File.read "/proc/#{@pid}/" + file
  rescue ex
    raise "#{ex}\nVerify if a process that have a pid number of '#{pid}' exists"
  end

  def self.all(cpu_time = false, cpu_total = false)
    Dir.each_child "/proc" do |pid_dir|
      if pid = pid_dir.to_i?
        yield Hardware::PID.new(pid: pid, cpu_time: false, cpu_total: false)
      end
    end
  end

  def self.get_pids(executable : String)
    pids = Array(Int32).new
    all do |pid|
      pid_name = pid.name
      pids << pid.pid if pid_name == executable
    end
    pids
  end

  def cmdline
    read_proc("cmdline").gsub('\0', ' ')
  end

  def cpu_time(children = false)
    current_stat = stat

    if children
      current_stat[14].to_i + current_stat[15].to_i + current_stat[16].to_i + current_stat[17].to_i
    else
      current_stat[14].to_i + current_stat[15].to_i
    end
  end

  def cpu_used
    cpu_time_current = cpu_time
    @@cpu_total_current = CPU.info[:total] if @cpu_total

    # 100 * Usage / Total
    result = 100 * ((cpu_time_current - @cpu_time_previous.to_f32) / (@@cpu_total_current - @cpu_total_previous))

    @cpu_time_previous = cpu_time_current if @cpu_time
    @cpu_total_previous = @@cpu_total_current
    result
  end

  def exe
    if File.readable? path = "/proc/#{@pid}/exe"
      File.real_path path
    end
  rescue
    nil
  end

  # Assuming that PAGESIZE is 4096 kB
  def memory
    statm.first * 4
  end

  def name
    File.basename (command = exe) ? command : cmdline
  end

  def stat
    # CPU time spent in:
    # [14] utime - user
    # [15] stime - kernel
    # [16] cutime - user, including time from children
    # [17] cstime - kernel, including time from children
    read_proc("stat").split ' '
  end

  def statm
    read_proc("statm").split(' ').map &.to_i
  end

  def status
    status_hash = Hash(String, String).new
    read_proc("status").each_line do |line|
      key, value = line.split ":\t"
      status_hash[key] = value
    end
    status_hash
  end
end
