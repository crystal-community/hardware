# hardware

[![Build Status](https://travis-ci.org/crystal-community/hardware.svg?branch=master)](https://travis-ci.org/crystal-community/hardware)

This is a very basic module to help get CPU and memory usage of the current running OS

Tested on Linux.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  hardware:
    github: crystal-community/hardware
```

## Usage

#### Methods included in the `Hardware::CPU` struct:

`.new`

Creates a new `Hardware::CPU` based on the current memory state.

`#info : NamedTuple(used: Int32, idle: Int32, total: Int32)`

Returns the current used, idle and total CPU time.

`#previous_info : NamedTuple(used: Int32, idle: Int32, total: Int32)`

Returns the previous used, idle and total CPU time. Used to store the previous CPU time informations to calculate the percentage in`.used`.

`#stat : Array(Int32)`

Returns a parsed `/proc/stat`.

`#used(update = true) : Int32`

Returns the CPU used in percentage based on `@@previous_info`.

`user nice system idle iowait irq softirq steal guest guest_nice : Int32`

Instance methods based on `#stat`.

#### Methods included in the `Hardware::Memory` struct:

`.new`

Creates a new `Hardware::Memory` based on the current memory state.

`#available : Int32`

Returns the available memory in KiloBytes.

`#meminfo : Hash(String, Int64)`

Returns an Hash from a parsed `/proc/meminfo`.

`#percent(used = true) : Int32`

Returns either the used/available memory in percentage.

`#total : Int32`

Returns the total memory in KiloBytes.

`#used : Int32`

Returns the memory used in KiloBytes.

#### Methods included in the `Hardware::PID` struct:

`.new(@pid : Int32 = Process.pid, @cpu_time = true, @cpu_total = true)`

Creates a new `Hardware::PID`. `@cpu_time` and `@cpu_total` updates the CPU time informations. Set to false if lots of `Hardware::PID` are created.

`.new(executable : String, cpu_time = true, cpu_total = true)`

Creates a new `Hardware::PID` by finding the `executable`'s pid.

`.all(cpu_time = false, cpu_total = false) : Hardware::PID`

Yields a `Hardware::PID` for each PID existing on the system.

`#command : String`

Returns a String representation of `/proc/@pid/cmdline`.

`#cmdline : String`

Returns `/proc/@pid/cmdline`.

`#cpu_time(children = false)`

Returns the CPU time without including ones from `children` processes.

`#cpu_used : Float32`

Returns the CPU used in percentage.

`#exe : String | Nil`

Returns `/proc/@pid/exe` if readable.

`.get_pids(executable : String) : Array(Int32)`

Return all pids corresponding of a given `executable` name.

`#memory : Int32`

Returns the actual memory used by the process.

`#name : String`

Returns the PID name based on `#exe` or `#cmdline`.

`.cpu_total_current : Int32`

Returns `@@cpu_total_current`.

`#cpu_total_previous : Int32`

Returns `@cpu_total_previous`.

`#cpu_time_previous : Int32`

Returns `@cpu_time_previous`.

`#stat : Array(String)`

Returns a parsed `/proc/@pid/stat`.

`#statm : Array(Int32)`

Returns a parsed `/proc/@pid/statm`.

`#status : Hash(String, String)`

Returns a parsed `/proc/@pid/status`.

`ppid pgrp session tty_nr tpgid flags minflt cminflt majflt cmajflt utime stime cutime cstime priority nice numthreads itrealvalue starttime vsize rss : Int32`

Instance methods based on `#stat`.

## Examples

```crystal
require "hardware"

memory = Hardware::Memory.new
memory.used         #=> 2731404
memory.percent.to_i #=> 32

cpu = Hardware::CPU.new
pid = Hardware::PID.new(1)         # Default Process.pid.
app = Hardware::PID.new("firefox") # Take the first matching PID

loop do
  sleep 1
  cpu.used.to_i     #=> 17
  pid.cpu_used      #=> 1.5
  app.cpu_used.to_i #=> 4
end
```
## Development

### Docker

You can run the specs in a Docker container:

```sh
$ docker-compose up
$ docker-compose run spec
```

## Contributing

1. Fork it ( https://github.com/crystal-community/hardware/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [bararchy](https://github.com/bararchy) - creator, maintainer   
- [j8r](https://github.com/j8r) - contributor  
