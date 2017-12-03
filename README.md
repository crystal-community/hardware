# hardware

This is a very basic module to help get CPU and memory usage of the current running OS

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  hardware:
    github: NeuraLegion/hardware
```

## Usage

```crystal
require "hardware"
```

Output is a string representing percentage used.
```crystal
Hardware.mem_used => 12
Hardware.cpu_used => 15
```

## Development

This is currently working on Arch Linux, it behaves wierd on Ubuntu.
Maybe a way to define working enviroment is needed

```crystal
h = Hardware.new("ubuntu")
h.mem_used
```

Still needs research

## Contributing

1. Fork it ( https://github.com/NeuraLegion/hardware/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [bararchy](https://github.com/bararchy) - creator, maintainer
