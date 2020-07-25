require "../error/invalid_device"

require "../power_supply"

# Battery related informations
#
# ```
# # Run the command below to manually find the device available
# # `ls /sys/class/power_supply/`
# battery = Hardware::Battery.new("BAT0") # Specify the batery device name by yourself
# battery = Hardware::Battery.new_single  # Will be looking for one available battery device
# ```
class Hardware::Battery < Hardware::PowerSupply
  enum Status
    Unknown
    Charging
    Discharging
    NotCharging
    Full
  end

  def initialize(@supply_name : String)
    @current_device_path = Path.new(DEVICE_DIRECTORY, supply_name)

    unless type == "Battery"
      raise InvalidDevice.new "Not a battery"
    end
  end

  # Select one of the battery device available
  def initialize
    battery_power_device = PowerSupply.entries.find { |entry| entry.is_a? Battery }
    if battery_power_device
      initialize(battery_power_device.supply_name)
    else
      raise InvalidDevice.new "No battery device found"
    end
  end

  # The current battery power charge percentage
  def capacity : UInt8
    File.read(@current_device_path / "capacity").to_u8
  end

  # The current battery status
  def status : Status
    content = File.read(@current_device_path / "status").rstrip
    Status.parse?(content.delete(' ')).not_nil!
  end
end
