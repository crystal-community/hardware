require "./lib_c"

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

  # Time
  getter idle : UInt64
  getter kernel : UInt64
  getter user : UInt64
  getter dpc : UInt64

  getter used : UInt64 { @kernel + @user }
  getter idle_total : UInt64 { @idle }
  getter total : UInt64 { @used + @idle }

  # Creates a new CPU stat to monitor the given core.
  #
  # Must be lower than `System.cpu_count`, or `nil` for the whole cores in total.
  def initialize(number : Int32? = nil)
    if @number = number
      raise "CPU number must be superior or equal to 0, and inferior to #{System.cpu_count}" unless 0 <= number < System.cpu_count
    end

    @idle = 0
    @kernel = 0
    @user = 0
    @dpc = 0
    get_data
  end

  def get_data
    system_processor_performance_information = Pointer(LibC::SYSTEM_PROCESSOR_PERFORMANCE_INFORMATION_OUTPUT)
      .malloc(System.cpu_count)
    # TODO
    # Handle error
    LibC.ntQuerySystemInformation(
      LibC::SYSTEM_PROCESSOR_PERFORMANCE_INFORMATION_VAL,
      system_processor_performance_information,
      sizeof(LibC::SYSTEM_PROCESSOR_PERFORMANCE_INFORMATION) * System.cpu_count,
      Pointer(LibC::ULONG).null)
    @idle = 0
    @kernel = 0
    @user = 0
    @dpc = 0
    (0...System.cpu_count).each do |nth_cpu|
      cpu = system_processor_performance_information[nth_cpu]
      @idle += cpu.idleTime.quadPart
      @kernel += cpu.kernelTime.quadPart
      @user += cpu.userTime.quadPart
      @dpc += cpu.dpcTime.quadPart
    end
  end

  # TODO
  # Verify
  def usage(previous_cpu : CPU = self) : Float64
    delta_kernel = @kernel - previous_cpu.kernel
    delta_idle = @idle - previous_cpu.idle
    delta_user = @user - previous_cpu.user

    (delta_kernel + delta_user - delta_idle) * 100.0 / (delta_kernel + delta_user)
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
    previous_cpu = self
    get_data
    usage previous_cpu
  end
end
