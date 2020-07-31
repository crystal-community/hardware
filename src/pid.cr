require "./cpu"

# All informations related to the Processes running on your sytem, defined by Process IDentifiers.
#
# ```
# pid = Hardware::PID.new           # Default is Process.pid
# app = Hardware::PID.new "firefox" # Take the first matching PID
# ```
struct Hardware::PID
  # Pid number
  getter number : Int64

  # Creates a new `Hardware::PID`.
  def initialize(@number : Int64 = Process.pid)
    raise Error.new "Pid #{number} doesn't exist" if !exists?
  end

  # Creates a new `Hardware::PID` by finding the `executable`'s pid.
  def self.new(executable : String)
    match_pid = nil
    get_pids executable do |pid|
      match_pid = pid
      break
    end
    raise Error.new "No pid for '#{executable}' exists" if !match_pid
    new match_pid
  end

  private def read_proc(file : String, & : IO ->)
    File.open "/proc/#{@number}/#{file}" do |io|
      yield io
    end
  rescue ex
    raise Exception.new "No such process having a pid number of '#{@number}'", ex
  end

  # Yields a `Hardware::PID` for each PID present on the system.
  def self.each(& : PID ->) : Nil
    Dir.each_child "/proc" do |pid_dir|
      if pid = pid_dir.to_i64?
        yield Hardware::PID.new pid
      end
    end
  end

  # Yield each pids corresponding to a given `executable` name.
  def self.get_pids(executable : String, & : Int64 ->)
    each do |pid|
      yield pid.number if pid.name == executable
    end
  end

  # Returns a `String` representation of `/proc/``#pid``/cmdline`.
  def command : String
    cmdline.gsub '\0', ' '
  end

  # Returns `/proc/``#pid``/cmdline`.
  def cmdline : String
    read_proc "cmdline", &.gets_to_end
  end

  # Returns `/proc/``#pid``/exe` if readable.
  def exe : String
    File.real_path "/proc/#{@number}/exe"
  end

  def exists? : Bool
    Dir.exists? "/proc/#{@number}"
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
    Net.new @number
  end

  # Returns a parsed `/proc/``#pid``/stat`.
  #
  # Have CPU information of the process.
  # ```
  # pid_stat = Hardware::PID.new.stat
  # loop do
  #   sleep 1
  #   p pid_stat.cpu_usage! # => 1.5
  # end
  # ```
  def stat(cpu : CPU? = CPU.new) : Stat
    Stat.new @number, cpu
  end

  # Returns a parsed `/proc/``#pid``/statm`.
  def statm : Array(Int32)
    values = Array(Int32).new
    read_proc "statm", &.gets_to_end.split ' ' do |int|
      values << int.to_i
    end
    values
  end

  # Returns a parsed `/proc/``#pid``/status`.
  def status : Status
    read_proc "status" do |io|
      Status.new io
    end
  end
end

require "./pid/*"
