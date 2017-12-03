require "./hardware/*"

module Hardware
  def self.mem_used
    if File.exists?("/proc/meminfo")
      File.open("/proc/meminfo", "r") do |file|
        result = file.gets_to_end
        memstat = result.split("\n").select { |x| x.strip }
        memtotal = memstat[0].gsub(/[^0-9]/, "")
        memactive = memstat[6].gsub(/[^0-9]/, "")
        memactivecalc = (memactive.to_f32 * 100) / memtotal.to_f32
        return memactivecalc.round
      end
    end
  end

  def self.cpu_used
    proc0 = File.read("/proc/stat").each_line.grep(/^cpu /).first.split(" ")[2..-1]
    sleep 1
    proc1 = File.read("/proc/stat").each_line.grep(/^cpu /).first.split(" ")[2..-1]

    proc0usagesum = proc0[0].to_i + proc0[1].to_i + proc0[2].to_i
    proc1usagesum = proc1[0].to_i + proc1[1].to_i + proc1[2].to_i
    procusage = proc1usagesum - proc0usagesum

    proc0total = 0
    (1..4).each do |i|
      proc0total += proc0[i].to_i
    end
    proc1total = 0
    (1..4).each do |i|
      proc1total += proc1[i].to_i
    end
    proctotal = (proc1total - proc0total)

    cpuusage = (procusage.to_f32 / proctotal.to_f32)
    return (100 * cpuusage).to_f32.round(2)
  end
end
