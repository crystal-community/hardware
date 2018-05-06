# hardware

[![GitHub release](https://img.shields.io/github/release/crystal-community/hardware.svg)](https://github.com/crystal-community/hardware/releases)
[![Build Status](https://travis-ci.org/crystal-community/hardware.svg?branch=master)](https://travis-ci.org/crystal-community/hardware)

A basic module to get CPU, memory and network informations of the current running OS and its processes.

Tested on Linux.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  hardware:
    github: crystal-community/hardware
```

## Documentation

The documentation is accessible at https://crystal-community.github.io/hardware.

It is generated with [crystal docs](https://crystal-lang.org/docs/conventions/documenting_code.html) in the `gh-pages` branch.

## Examples

```crystal
require "hardware"

memory = Hardware::Memory.new
memory.used         #=> 2731404
memory.percent.to_i #=> 32

cpu = Hardware::CPU.new
pid = Hardware::PID.new           # Default is Process.pid
app = Hardware::PID.new "firefox" # Take the first matching PID

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
