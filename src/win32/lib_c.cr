@[Link("Ntdll")]
@[Link("Kernel32")]
lib LibC
  alias DWORDLONG = UInt64
  alias LONGLONG = Int64

  # Memory
  struct MEMORYSTATUSEX
    dwLength : DWORD
    dwMemoryLoad : DWORD
    ullTotalPhys : DWORDLONG
    ullAvailPhys : DWORDLONG
    ullTotalPageFile : DWORDLONG
    ullAvailPageFile : DWORDLONG
    ullTotalVirtual : DWORDLONG
    ullAvailVirtual : DWORDLONG
    ullAvailExtendedVirtual : DWORDLONG
  end

  alias LPMEMORYSTATUSEX = MEMORYSTATUSEX*

  fun globalMemoryStatusEx = GlobalMemoryStatusEx(lpBuffer : LPMEMORYSTATUSEX) : BOOL

  # CPU
  struct SYSTEM_PROCESSOR_PERFORMANCE_INFORMATION_OUTPUT
    idleTime : LARGE_INTEGER
    kernelTime : LARGE_INTEGER
    userTime : LARGE_INTEGER
    dpcTime : LARGE_INTEGER
    interruptTime : LARGE_INTEGER
    interruptCount : ULONG
  end

  struct LARGE_INTEGER_STRUCT
    lowPart : DWORD
    highPart : LONG
  end

  union LARGE_INTEGER
    highLowStruct : LARGE_INTEGER_STRUCT
    quadPart : LONGLONG
  end

  SYSTEM_PROCESSOR_PERFORMANCE_INFORMATION = 8

  fun ntQuerySystemInformation = NtQuerySystemInformation(systemInformationClass : Int32, systemInformation : Void*, systemInformationLength : ULONG, returnLength : ULONG*)
end
