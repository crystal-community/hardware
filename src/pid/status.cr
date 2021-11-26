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

  macro define_getters(*keys)
    {% for key in keys %}
      def {{ key.downcase.id }}
        {{ @data[key] }}
      end
    {% end %}
  end
  
  define_getters @data.keys
 
  enum Field
    Key
    Blank
    Value
  end

  protected def initialize(io : IO)
    buffer = IO::Memory.new
    key = ""
    state = Field::Key

    io.each_char do |char|
      
      case state
      when Field::Key
        if char == ':'
          key = buffer.to_s
          buffer.clear
          state = Field::Blank
        else
          buffer << char
        end
      
      when Field::Blank
        if char.alphanumeric?
          buffer << char
          state = Field::Value
        end
    
      when Field::Value
        if char == '\n'
          data[key] = buffer.to_s
          buffer.clear
          state = Field::Key
          key = ""
        else
          buffer << char
        end
      end

    end
  end
end
