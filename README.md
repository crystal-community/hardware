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

#### Methods included in the `Hardware::CPU` module:

`.info : NamedTuple(used: Int32, idle: Int32, total: Int32)`

Returns a NamedTuple including the used, idle and total CPU time.

`.used(sleep_time = 1) : Int32`

Returns the cpu used in percentage in the last `sleep_time` seconds.

#### Methods included in the `Hardware::Memory` struct:

`.new`

Creates a new `Hardware::Memory` based on the current memory state.

`#available : Int32`

Returns the available memory in KiloBytes.

`#meminfo : Hash(String, Int64)`

Returns an Hash from a parsed `/proc/meminfo`

`#percent(used = true) : Int32`

Returns either the used/available memory in percentage.

`#total : Int32`

Returns the total memory in KiloBytes.

`#used : Int32`

Returns the memory used in KiloBytes.

## Examples

```crystal
require "hardware"

memory = Hardware::Memory.new
memory.used        #=> 2731404
memory.percent     #=> 32

Hardware::CPU.used #=> 12

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
