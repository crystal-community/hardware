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

  def initialize(supply_name : String)
    @current_device_path = Path.new("#{DEVICE_DIRECTORY}/#{supply_name}")

    unless type == Type::Battery
      raise "Not a battery"
    end
  end

  def self.new_single
    battery_power_device = self.entries_with_type.find { |entry| entry.type == Type::Battery }
    if battery_power_device
      self.new(battery_power_device.name)
    else
      raise "No battery device found"
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
