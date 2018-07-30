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
  @netstat : Array(String)

  # Creates a new `Hardware::Net` for the System.
  def initialize
    # IpExt is on the last line
    @netstat = File.read("/proc/net/netstat").lines.last[7..-1].split(' ')
  end

  # Creates a new `Hardware::Net` for a PID.
  def initialize(pid : Int32 = Process.pid)
    # IpExt is on the last line
    @netstat = File.read("/proc/#{pid}/net/netstat").lines.last[7..-1].split(' ')
  end

  # Generate methods based on stat
  {% begin %}{% i = 0 %}
  {% for num in %w(
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
    # Returns the "{{num.id}}" field of `net/netstat`. {% if i > 11 %} Only in recent versions of Linux {% end %}
    def {{num.id.underscore}} : Int64
      @netstat[{{i}}].to_i64
    end
    {% i = i + 1 %}
  {% end %}{% end %}
end
