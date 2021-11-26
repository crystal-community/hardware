struct Hardware::PID::Status
  getter data : Hash(String, String)

  def initialize(file_content : String?)
    @data = {
      "Name"         => "",
      "Umask"        => "",
      "State"        => "",
      "Tgid"         => "",
      "Ngid"         => "",
      "Pid"          => "",
      "PPid"         => "",
      "TracerPid"    => "",
      "Uid"          => "",
      "Gid"          => "",
      "FDSize"       => "",
      "Groups"       => "",
      "NStgid"       => "",
      "NSpid"        => "",
      "NSpgid"       => "",
      "NSsid"        => "",
      "VmPeak"       => "",
      "VmSize"       => "",
      "VmLck"        => "",
      "VmPin"        => "",
      "VmHWM"        => "",
      "VmRSS"        => "",
      "RssAnon"      => "",
      "RssFile"      => "",
      "RssShmem"     => "",
      "VmData"       => "",
      "VmStk"        => "",
      "VmExe"        => "",
      "VmLib"        => "",
      "VmPTE"        => "",
      "VmSwap"       => "",
      "HugetlbPages" => "",
      "CoreDumping"  => "",
      "THP_enabled"  => "",
      "Threads"      => "",
    }

    return unless file_content

    file_content.each_line do |l|
      key, value = l.delete(' ').delete('\t').split(':')
      @data[key] = value
      break if key == "Threads"
    end
  end

  # PID's status name.
  getter name : String { @data["Name"] }

  # PID's status umask.
  getter umask : String { @data["Umask"] }

  # PID's status state.
  getter state : String { @data["State"] }
end
