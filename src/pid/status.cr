struct Hardware::PID::Status
  getter data : Hash(String, String) = Hash(String, String).new

  protected def initialize(io : IO)
    @data = Hash(String, String).new
    buffer = IO::Memory.new
    key = ""
    io.each_char do |char|
      case char
      when ' '
        # skip
      when ':'
        key = buffer.to_s
        buffer.clear
      when '\n'
        @data[key] = buffer.to_s
      else
        buffer << char
      end
    end
  end

  # PID's status name.
  getter name : String { @data["Name"] }

  # PID's status state.
  getter umask : String { @data["Umask"] }

  # PID's status state.
  getter state : String { @data["State"] }
end
