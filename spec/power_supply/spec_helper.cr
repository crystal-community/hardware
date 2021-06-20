require "../../src/power_supply"

abstract struct Hardware::PowerSupply
  def self.device_directory=(device_directory)
    @@device_directory = device_directory
  end
end
