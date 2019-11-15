# Network informations about the system or a process like the brandwidth use.
#
# Example of network brandwidth calculation:
# ```
# net = Hardware::Net.new # System network stats
# old_in, old_out = net.in_octets, net.out_octets
# loop do
#   sleep 1
#   net = Hardware::Net.new # Update network stats
#   now_in, now_out = net.in_octets, net.out_octets
#   puts "down: #{(now_in - old_in) / 1000}kB/s | up: #{(now_out - old_out) / 1000}kB/s" # => down: 427kB/s | up: 24kB/s
#   old_in, old_out = now_in, now_out
# end
# ```
struct Hardware::Net
  getter pid : Int32? = nil
  getter tcp_ext : Hash(String, Int64) = Hash(String, Int64).new
  getter ip_ext : Hash(String, Int64) = Hash(String, Int64).new

  # Creates a new `Hardware::Net` for the system, or a given PID.
  def initialize(@pid : Int32? = nil)
    buffer = IO::Memory.new
    # netstat content:
    # TcpExt: SomeKey OtherKey ...
    # TcpExt: 0 0 ...
    # IpExt: InNoRoutes InTruncatedPkts ...
    # IpExt: 0 0 ...
    keys_row = true
    key = ""
    tcp_ext_keys = Array(String).new
    ip_ext_keys = Array(String).new
    File.open (@pid ? "/proc/#{@pid}/net/netstat" : "/proc/net/netstat"), &.each_char do |char|
      case char
      when ':'
        key = buffer.to_s
        buffer.clear
      when ' ', '\n'
        next if buffer.empty?
        case key
        when "TcpExt"
          if keys_row
            tcp_ext_keys << buffer.to_s
          else
            @tcp_ext[tcp_ext_keys.shift] = buffer.to_s.to_i64
          end
        when "IpExt"
          if keys_row
            ip_ext_keys << buffer.to_s
          else
            @ip_ext[ip_ext_keys.shift] = buffer.to_s.to_i64
          end
        end
        buffer.clear
      else
        buffer << char
      end
      if char == '\n'
        keys_row = !keys_row
        column_num = 0
      end
    end
  end

  # Generate methods based on stat
  {% begin %}
  {% i = 0 %} 
  {% for stat in %w(
                   InNoRoutes
                   InTruncatedPkts
                   InMcastPkts
                   OutMcastPkts
                   InBcastPkts
                   OutBcastPkts
                   InOctets
                   OutOctets
                   InMcastOctets
                   OutMcastOctets
                   InBcastOctets
                   OutBcastOctets
                   InCsumErrors
                   InNoEctPkts
                   InEct1Pkts
                   InEct0Pkts
                   InCePkts) %}
    # Returns the "{{stat}}" field of the `IpExt` field in `net/netstat`. {% if i > 11 %} Only in recent versions of Linux {% end %}
    def {{stat.id.underscore}} : Int64
      @ip_ext[{{stat}}]
    end
    {% i = i + 1 %}
  {% end %}
  {% end %}
end
