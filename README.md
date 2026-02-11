# NV Offsetter

## What is it?

A simple program aimed for a few specific purpose, floating around on GitHub just like many other similar tools.

## What does it do?

It specifically aims to:
- Offset graphics and memory clocks
- Cap minimum and maximum graphics clocks
- Be minimal
- Be a daemon (not yet implemented)
- Able to read from a config (also not yet implemented)

And does not:
- Have a GUI
- Have the ability to change fan curves

Todo list:
- [ ] PKGBUILD
- [ ] Read conf depending on install location
- [ ] Conf priority(?)
- [ ] Make types more concise (it's all int ATM)
- [ ] Proper frequency cap

## Development

Dependencies:
- cuda
- [confuse](https://github.com/libconfuse/libconfuse?tab=readme-ov-file)
- Linux (I only plan to make this work on the said platform)

Building:

```bash
make
```

## Usage

Before running, the following values must be set in `/etc/nv-offsetter.conf` in MHz:

```
graphics
graphics_min // Can be omitted
graphics_max
mem // The amount to offset in accordance to nvidia-smi, as the program hardcodes mem multiplier by 2
```

It doesn't have any arguments to begin with so you can run the program as-is (NVML requires super user priviledge to manipulate the device however):

```bash
sudo make run
```

## Contributing

Contributions are welcomed as long as the PR seems reasonable to me.

## Other notable tools

- [LACT](https://github.com/ilya-zlobintsev/LACT/) - A great tool for general users (in my opinion) who doesn't like using only CLI, or wants a featureful, better software that works on more than just NVIDIA GPUs. The aforementioned repository itself also refers to other tools which are worth checking out.
- [jacklul's NVML scripts](https://github.com/jacklul/nvml-scripts) - A similar implementation in Python.

## Why?

Back when I need a way to overclock and cap the clocks my GPU card, I didn't know many tools for such purpose that work on just cli, and the Python wrapper for NVML, while easy to script and use, did not appeal to me for a couple of personal reason.
Another motivation for this was because I wanted to try writing a low level software that has a practical use for me, hence the inception.
And who knows if someone likes it?
