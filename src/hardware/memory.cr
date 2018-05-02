# Memory related informations of your system.
#
# ```
# memory = Hardware::Memory.new
# memory.used         # => 2731404
# memory.percent.to_i # => 32
# ```
struct Hardware::Memory
  # VmallocTotal can be very huge - needs Int64

  # Returns an Hash from a parsed `/proc/meminfo`.
  getter meminfo = Hash(String, Int64).new

  # Creates a new `Hardware::Memory` based on the current memory state.
  def initialize
    File.read("/proc/meminfo").each_line do |line|
      properties = line.split ' '
      @meminfo[properties.first.rchop] = (properties.last == "kB" ? properties[-2] : properties.last).to_i64
    end
  end

  # Returns the total memory in KiloBytes.
  def total : Int32
    @meminfo["MemTotal"].to_i
  end

  # Returns the available memory in KiloBytes.
  def available : Int32
    # https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=34e431b0ae398fc54ea69ff85ec700722c9da773
    if mem_available = @meminfo["MemAvailable"]?
      mem_available
      # MemAvailable isn't present in older systems
    else
      @meminfo["MemFree"] - @meminfo["Buffers"] - @meminfo["Cached"] - @meminfo["SReclaimable"] - @meminfo["Shmem"]
    end.to_i
  end

  # Returns the memory used in KiloBytes.
  def used : Int32
    total - available
  end

  # Returns either the used/available memory in percentage.
  def percent(used = true) : Float32
    (used ? self.used : available).to_f32 * 100 / total
  end
end
