require "./lib_c"

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
  # Return a win32 MEMORYSTATUSEX struct
  # See https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-memorystatusex
  # for the details
  getter meminfo : LibC::MEMORYSTATUSEX

  # Creates a new `Hardware::Memory` based on the current memory state.
  def initialize
    @meminfo = LibC::MEMORYSTATUSEX.new
    @meminfo.dwLength = sizeof(LibC::MEMORYSTATUSEX)
    LibC.globalMemoryStatusEx(pointerof(@meminfo))
    pp @meminfo
  end

  # Returns the total memory in KiloBytes.
  getter total : Int32 do
    (@meminfo.ullTotalPhys / 1000).to_i32
  end

  # Returns the available memory in KiloBytes.
  getter available : Int32 do
    (@meminfo.ullAvailPhys / 1000).to_i32
  end

  # Returns the memory used in KiloBytes.
  getter used : Int32 { total - available }

  # Returns either the used/available memory in percentage.
  def percent(used : Bool = true) : Float64
    (used ? @meminfo.dwMemoryLoad : 100 - @meminfo.dwMemoryLoad).to_f64
  end
end
