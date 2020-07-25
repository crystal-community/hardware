require "./error/invalid_device"

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
  getter supply_name : String

  @type : String | Nil = nil
  @serial_number : String | Nil = nil
  @model_name : String | Nil = nil
  @manufacturer : String | Nil = nil

  def initialize(@supply_name : String, check_if_exists : Bool = true)
    @current_device_path = Path.new(DEVICE_DIRECTORY, supply_name)
    if check_if_exists && !Dir.exists?(@current_device_path)
      raise InvalidDevice.new "#{supply_name} is not a valid device name"
    end
  end

  def self.new_with_type(supply_name : String) : PowerSupply
    power_supply = self.new(supply_name)
    type = power_supply.type
    case type
    when "Battery"
      Hardware::Battery.new(supply_name)
    when "Mains"
      Hardware::Mains.new(supply_name)
    when "UPS"
      Hardware::UPS.new(supply_name)
    when "USB"
      Hardware::USB.new(supply_name)
    else
      power_supply
    end
  end

  # Initialize the struct without checking the device validity
  def self.new!(supply_name : String)
    self.new(supply_name, false)
  end

  # Get entries name of the available device
  def self.entries_name : Array(String)
    entries = [] of String
    Dir.each DEVICE_DIRECTORY do |filename|
      unless filename.starts_with?('.')
        entries << filename
      end
    end
    entries
  end

  def self.entries : Array(PowerSupply)
    self.entries_name.reduce([] of PowerSupply) do |entries, name|
      entries << PowerSupply.new_with_type(name)
    end
  end

  # Describes the main type of the supply
  # It can be Battery, UPS, Mains, or USB. See Hardware::PowerSupply::Type
  def type : String | Nil
    unless @type
      @type = File.read(@current_device_path / "type").rstrip
    end
    @type
  end

  # Reports the serial number of the device
  def serial_number : String | Nil
    unless @serial_number
      @serial_number = File.read(@current_device_path / "serial_number").rstrip
    end
    @serial_number
  end

  # Reports the name of the device model
  def model_name : String | Nil
    unless @model_name
      @model_name = File.read(@current_device_path / "model_name").rstrip
    end
    @model_name
  end

  # Reports the name of the device manufacturer
  def manufacturer : String | Nil
    unless @manufacturer
      @manufacturer = File.read(@current_device_path / "manufacturer").rstrip
    end
    @manufacturer
  end
end

require "./power_supply/battery"
require "./power_supply/mains"
require "./power_supply/ups"
require "./power_supply/usb"
