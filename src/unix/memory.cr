# Memory related informations of your system.
#
# Most values are in kB, except HugePages ones.
#
# ```
# memory = Hardware::Memory.new
# memory.used         # => 2731404
# memory.percent.to_i # => 32
# ```
struct Hardware::Memory
  # VmallocTotal can be very huge - needs Int64

  # Returns an Hash from a parsed `/proc/meminfo`.
  getter meminfo : Hash(String, Int64) = Hash(String, Int64).new

  # Creates a new `Hardware::Memory` based on the current memory state.
  def initialize
    buffer = IO::Memory.new
    key = ""
    # /proc/meminfo content:
    # MemTotal:       999999 kB
    # MemFree:        999999 kB
    end_value = false
    File.open "/proc/meminfo", &.each_char do |char|
      case char
      when ' '
        # skip
        # Don't add kB to the value buffer
        end_value = true if !buffer.empty?
      when ':'
        key = buffer.to_s
        buffer.clear
      when '\n'
        @meminfo[key] = buffer.to_s.to_i64
        buffer.clear
        end_value = false
      else
        buffer << char if !end_value
      end
    end
  end

  # Returns the total memory in KiloBytes.
  getter total : Int32 { @meminfo["MemTotal"].to_i }

  # Returns the available memory in KiloBytes.
  getter available : Int32 do
    # https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=34e431b0ae398fc54ea69ff85ec700722c9da773
    if mem_available = @meminfo["MemAvailable"]?
      mem_available
      # MemAvailable isn't present in older systems
    else
      @meminfo["MemFree"] - @meminfo["Buffers"] - @meminfo["Cached"] - @meminfo["SReclaimable"] - @meminfo["Shmem"]
    end.to_i
  end

  # Returns the memory used in KiloBytes.
  getter used : Int32 { total - available }

  # Returns either the used/available memory in percentage.
  def percent(used : Bool = true) : Float64
    (used ? self.used : available) * 100 / total
  end
end
