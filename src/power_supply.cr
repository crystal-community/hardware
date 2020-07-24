# Power supply related informations
#
# ```
# # Run the command below to manually find the device available
# # `ls /sys/class/power_supply/`
# power_supply = Hardware::PowerSupply.new("BAT0") # Specify the batery device name by yourself
# ```
class Hardware::PowerSupply
  DEVICE_DIRECTORY = "/sys/class/power_supply"

  @current_device_path : Path

  enum Type : UInt8
    Battery
    UPS
    Mains
    USB
  end

  def initialize(supply_name : String)
    @current_device_path = Path.new("#{DEVICE_DIRECTORY}/#{supply_name}")
  end

  # Get entries of the available device
  def self.entries
    Dir.entries(DEVICE_DIRECTORY).reject { |filename| filename.starts_with?('.') }
  end

  record EntryType, name : String, type : Type

  # Get entries of the available device with the device type
  def self.entries_with_type
    self.entries.reduce([] of EntryType) do |entries, filename|
      entries << EntryType.new(filename, PowerSupply.new(filename).type)
    end
  end

  # Describes the main type of the supply
  # It can be Battery, UPS, Mains, or USB. See Hardware::PowerSupply::Type
  def type : Type
    content = File.read(@current_device_path / "type").rstrip
    Type.parse?(content).not_nil!
  end

  # Reports the serial number of the device
  def serial_number : String
    File.read(@current_device_path / "serial_number").rstrip
  end

  # Reports the name of the device model
  def model_name : String
    File.read(@current_device_path / "model_name").rstrip
  end

  # Reports the name of the device manufacturer
  def manufacturer : String
    File.read(@current_device_path / "manufacturer").rstrip
  end
end
