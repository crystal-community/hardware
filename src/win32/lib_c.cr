@[Link("Kernel32")]
lib LibC
  alias DWORDLONG = UInt64

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
end
