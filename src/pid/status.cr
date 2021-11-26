struct Hardware::PID::Status
  getter data : Hash(String, String) = {
    "Name"                       => "",
    "Umask"                      => "",
    "State"                      => "",
    "Tgid"                       => "",
    "Ngid"                       => "",
    "Pid"                        => "",
    "PPid"                       => "",
    "TracerPid"                  => "",
    "Uid"                        => "",
    "Gid"                        => "",
    "FDSize"                     => "",
    "Groups"                     => "",
    "NStgid"                     => "",
    "NSpid"                      => "",
    "NSpgid"                     => "",
    "NSsid"                      => "",
    "VmPeak"                     => "",
    "VmSize"                     => "",
    "VmLck"                      => "",
    "VmPin"                      => "",
    "VmHWM"                      => "",
    "VmRSS"                      => "",
    "RssAnon"                    => "",
    "RssFile"                    => "",
    "RssShmem"                   => "",
    "VmData"                     => "",
    "VmStk"                      => "",
    "VmExe"                      => "",
    "VmLib"                      => "",
    "VmPTE"                      => "",
    "VmSwap"                     => "",
    "HugetlbPages"               => "",
    "CoreDumping"                => "",
    "THP_enabled"                => "",
    "Threads"                    => "",
    "SigQ"                       => "",
    "SigPnd"                     => "",
    "ShdPnd"                     => "",
    "SigBlk"                     => "",
    "SigIgn"                     => "",
    "SigCgt"                     => "",
    "CapInh"                     => "",
    "CapPrm"                     => "",
    "CapEff"                     => "",
    "CapBnd"                     => "",
    "CapAmb"                     => "",
    "NoNewPrivs"                 => "",
    "Seccomp"                    => "",
    "Seccomp_filters"            => "",
    "Speculation_Store_Bypass"   => "",
    "SpeculationIndirectBranch"  => "",
    "Cpus_allowed"               => "",
    "Cpus_allowed_list"          => "",
    "Mems_allowed"               => "",
    "Mems_allowed_list"          => "",
    "voluntary_ctxt_switches"    => "",
    "nonvoluntary_ctxt_switches" => "",
  }

  getter name : String { @data["Name"] }
  getter umask : String { @data["Umask"] }
  getter state : String { @data["State"] }
  getter tgid : String { @data["Tgid"] }
  getter ngid : String { @data["Ngid"] }
  getter pid : String { @data["Pid"] }
  getter ppid : String { @data["PPid"] }
  getter tracerpid : String { @data["TracerPid"] }
  getter uid : String { @data["Uid"] }
  getter gid : String { @data["Gid"] }
  getter fdsize : String { @data["FDSize"] }
  getter groups : String { @data["Groups"] }
  getter nstgid : String { @data["NStgid"] }
  getter nspid : String { @data["NSpid"] }
  getter nspgid : String { @data["NSpgid"] }
  getter nssid : String { @data["NSsid"] }
  getter vmpeak : String { @data["VmPeak"] }
  getter vmsize : String { @data["VmSize"] }
  getter vmlck : String { @data["VmLck"] }
  getter vmpin : String { @data["VmPin"] }
  getter vmhwm : String { @data["VmHWM"] }
  getter vmrss : String { @data["VmRSS"] }
  getter rssanon : String { @data["RssAnon"] }
  getter rssfile : String { @data["RssFile"] }
  getter rssshmem : String { @data["RssShmem"] }
  getter vmdata : String { @data["VmData"] }
  getter vmstk : String { @data["VmStk"] }
  getter vmexe : String { @data["VmExe"] }
  getter vmlib : String { @data["VmLib"] }
  getter vmpte : String { @data["VmPTE"] }
  getter vmswap : String { @data["VmSwap"] }
  getter hugetlbpages : String { @data["HugetlbPages"] }
  getter coredumping : String { @data["CoreDumping"] }
  getter thp_enabled : String { @data["THP_enabled"] }
  getter threads : String { @data["Threads"] }
  getter sigq : String { @data["SigQ"] }
  getter sigpnd : String { @data["SigPnd"] }
  getter shdpnd : String { @data["ShdPnd"] }
  getter sigblk : String { @data["SigBlk"] }
  getter sigign : String { @data["SigIgn"] }
  getter sigcgt : String { @data["SigCgt"] }
  getter capinh : String { @data["CapInh"] }
  getter capprm : String { @data["CapPrm"] }
  getter capeff : String { @data["CapEff"] }
  getter capbnd : String { @data["CapBnd"] }
  getter capamb : String { @data["CapAmb"] }
  getter nonewprivs : String { @data["NoNewPrivs"] }
  getter seccomp : String { @data["Seccomp"] }
  getter seccomp_filters : String { @data["Seccomp_filters"] }
  getter speculation_store_bypass : String { @data["Speculation_Store_Bypass"] }
  getter speculationindirectbranch : String { @data["SpeculationIndirectBranch"] }
  getter cpus_allowed : String { @data["Cpus_allowed"] }
  getter cpus_allowed_list : String { @data["Cpus_allowed_list"] }
  getter mems_allowed : String { @data["Mems_allowed"] }
  getter mems_allowed_list : String { @data["Mems_allowed_list"] }
  getter voluntary_ctxt_switches : String { @data["voluntary_ctxt_switches"] }
  getter nonvoluntary_ctxt_switches : String { @data["nonvoluntary_ctxt_switches"] }

  enum ReadState
    Key
    Blank
    Value
  end

  protected def initialize(io : IO)
    buffer = IO::Memory.new
    key = ""
    state = ReadState::Key

    io.each_char do |char|
      case state
      when ReadState::Key
        if char == ':'
          key = buffer.to_s
          buffer.clear
          state = ReadState::Blank
        else
          buffer << char
        end
      when ReadState::Blank
        if char.alphanumeric?
          buffer << char
          state = ReadState::Value
        end
      when ReadState::Value
        if char == '\n'
          data[key] = buffer.to_s
          buffer.clear
          state = ReadState::Key
          key = ""
        else
          buffer << char
        end
      end
    end
  end
end
