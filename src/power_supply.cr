require "./error/invalid_device"

# Power supply related informations
#
# ```
# # Run the command below to manually find the device available
# # `ls /sys/class/power_supply/`
# power_supply = Hardware::PowerSupply.new("BAT0") # Specify the batery device name by yourself
# ```
abstract struct Hardware::PowerSupply
  class_getter device_directory : Path = Path.new("/sys/class/power_supply")

  @current_device_path : Path
  getter supply_name : String

  @type : String | Nil = nil
  # Describes the main type of the supply
  # It can be Battery, UPS, Mains, or USB. See Hardware::PowerSupply::Type
  getter type : String do
    unless @type
      @type = File.read(@current_device_path / "type").rstrip
    end
    @type
  end

  @serial_number : String | Nil = nil
  # Reports the serial number of the device
  getter serial_number : String do
    unless @serial_number
      @serial_number = File.read(@current_device_path / "serial_number").rstrip
    end
    @serial_number
  end

  @model_name : String | Nil = nil
  # Reports the name of the device model
  getter model_name : String do
    unless @model_name
      @model_name = File.read(@current_device_path / "model_name").rstrip
    end
    @model_name
  end

  @manufacturer : String | Nil = nil
  # Reports the name of the device manufacturer
  getter manufacturer : String do
    unless @manufacturer
      @manufacturer = File.read(@current_device_path / "manufacturer").rstrip
    end
    @manufacturer
  end

  def initialize(@supply_name : String, check_if_exists : Bool = true)
    @current_device_path = @@device_directory / @supply_name
    if check_if_exists && !Dir.exists?(@current_device_path)
      raise InvalidDevice.new "#{supply_name} is not a valid device name"
    end
  end

  def self.new_with_type(supply_name : String) : PowerSupply
    type = File.read(@@device_directory / supply_name / "type").rstrip
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
      raise InvalidDevice.new "#{supply_name} does not have a valid device type"
    end
  end

  # Initialize the struct without checking the device validity
  def self.new!(supply_name : String)
    self.new(supply_name, false)
  end

  # Get entries name of the available device
  def self.entries_name : Array(String)
    Dir.new(device_directory).each_child.to_a
  end

  def self.entries : Array(PowerSupply)
    self.entries_name.reduce([] of PowerSupply) do |entries, name|
      entries << PowerSupply.new_with_type(name)
    end
  end

  def self.each : Iterator(String)
    Dir.new(device_directory).each_child
  end
end

require "./power_supply/battery"
require "./power_supply/mains"
require "./power_supply/ups"
require "./power_supply/usb"
